package io.github.edufolly.flutter_bluetooth_serial

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.net.NetworkInterface

const val REQUEST_BLUETOOTH_PERMISSIONS: Int = 1451
const val REQUEST_BLUETOOTH: Int = 1337
const val REQUEST_DISCOVERABLE_BLUETOOTH: Int = 2137
const val BLUETOOTH_REQUEST_DISABLE: String =
    "android.bluetooth.adapter.action.REQUEST_DISABLE"

/**
 * @author Eduardo Folly
 */
class BluetoothMethodsWrapper(
    messenger: BinaryMessenger,
) : MethodCallHandler,
    ActivityResultListener,
    RequestPermissionsResultListener {
    private var pendingResultForActivityResult: Result? = null

    private var pendingPermissionsEnsureCallback: ((Boolean) -> Unit)? = null

    private val methodChannel =
        MethodChannel(messenger, "$NAMESPACE/methods").also {
            it.setMethodCallHandler(this)
        }

    private lateinit var activity: Activity

    private lateinit var discoveryWrapper: BluetoothDiscoveryWrapper

    private var bluetoothAdapter: BluetoothAdapter? = null

    fun config(
        activity: Activity,
        discoveryWrapper: BluetoothDiscoveryWrapper,
        bluetoothAdapter: BluetoothAdapter?,
    ) {
        this.activity = activity
        this.discoveryWrapper = discoveryWrapper
        this.bluetoothAdapter = bluetoothAdapter
    }

    fun close() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        intent: Intent?,
    ): Boolean =
        when (requestCode) {
            REQUEST_BLUETOOTH -> {
                pendingResultForActivityResult?.success(resultCode != 0)
                true
            }

            REQUEST_DISCOVERABLE_BLUETOOTH -> {
                pendingResultForActivityResult?.success(
                    if (resultCode == 0) -1 else resultCode,
                )
                true
            }

            else -> {
                false
            }
        }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean =
        when (requestCode) {
            REQUEST_BLUETOOTH_PERMISSIONS -> {
                pendingPermissionsEnsureCallback?.let {
                    it(checkGranted(grantResults))
                }
                true
            }

            else -> {
                false
            }
        }

//    private fun getBluetoothPermissionName(): String =
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            "nearby devices"
//        } else {
//            "location"
//        }

    private fun checkPermissions(vararg permissions: String): Boolean =
        checkGranted(
            permissions
                .map { activity.checkSelfPermission(it) }
                .toIntArray(),
        )

    private fun checkGranted(permissions: IntArray): Boolean =
        permissions.fold(true) { acc, permission ->
            acc && permission == PackageManager.PERMISSION_GRANTED
        }

    private fun ensurePermissions(
        callback: (Boolean) -> Unit,
        needPermissionOnOldVersions: Boolean = false,
    ) {
        val permissions: Array<String> =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                arrayOf(
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.BLUETOOTH_ADVERTISE,
                    Manifest.permission.BLUETOOTH_SCAN,
                )
            } else {
                if (needPermissionOnOldVersions) {
                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
                } else {
                    emptyArray<String>()
                }
            }

        if (!checkPermissions(*permissions)) {
            pendingPermissionsEnsureCallback = callback

            activity.requestPermissions(
                permissions,
                REQUEST_BLUETOOTH_PERMISSIONS,
            )

            return
        }

        callback(true)
    }

    @SuppressLint("MissingPermission", "HardwareIds", "PrivateApi")
    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        if (bluetoothAdapter == null) {
            if (call.method.equals("isAvailable")) {
                result.success(false)
            } else {
                result.error(
                    "bluetooth_unavailable",
                    "bluetooth is not available",
                    null,
                )
            }
            return
        }

        when (call.method) {
            "isAvailable" -> {
                result.success(true)
            }

            "isEnabled" -> {
                result.success(bluetoothAdapter?.isEnabled ?: false)
            }

            "openSettings" -> {
                activity.startActivity(
                    Intent(Settings.ACTION_BLUETOOTH_SETTINGS),
                )
                result.success(null)
            }

            "requestEnable" -> {
                if (bluetoothAdapter?.isEnabled == true) {
                    result.success(true)
                } else {
                    ensurePermissions({ granted ->
                        if (granted) {
                            pendingResultForActivityResult = result

                            activity.startActivityForResult(
                                Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                                REQUEST_BLUETOOTH,
                            )
                        } else {
                            result.success(false)
                        }
                    })
                }
            }

            "requestDisable" -> {
                if (bluetoothAdapter?.isEnabled == true) {
                    ensurePermissions({ granted ->
                        if (granted) {
                            pendingResultForActivityResult = result

                            activity.startActivityForResult(
                                Intent(BLUETOOTH_REQUEST_DISABLE),
                                REQUEST_BLUETOOTH,
                            )
                        } else {
                            result.success(false)
                        }
                    })
                } else {
                    result.success(true)
                }
            }

            "ensurePermissions" -> {
                ensurePermissions(result::success)
            }

            "getAddress" -> {
                if (!checkPermissions(Manifest.permission.BLUETOOTH_CONNECT)) {
                    result.success(null)
                    return
                }

                val address: String? = bluetoothAdapter?.address

                if (address != null && address != "02:00:00:00:00:00") {
                    result.success(address)
                    return
                }

                Log.d(
                    TAG,
                    "Local Bluetooth MAC address is hidden by system, " +
                        "trying other options...",
                )

                try {
                    // Requires `LOCAL_MAC_ADDRESS` which could be unavailable
                    // for third party applications...
                    val value: String? =
                        Settings.Secure.getString(
                            activity.contentResolver,
                            "bluetooth_address",
                        )

                    if (value != null) {
                        result.success(value)
                        return
                    }
                } catch (e: Exception) {
                    // Ignoring failure
                    // (since it isn't critical API for most applications)
                    Log.d(
                        TAG,
                        "Obtaining address using Settings Secure " +
                            "bank failed.",
                    )
                }

                Log.d(
                    TAG,
                    "Trying to obtain address using reflection " +
                        "against internal Android code",
                )

                try {
                    val mServiceField =
                        bluetoothAdapter
                            ?.javaClass
                            ?.getDeclaredField("mService")

                    mServiceField?.isAccessible = true

                    val bluetoothManagerService =
                        mServiceField?.get(bluetoothAdapter)

                    if (bluetoothManagerService == null) {
                        if (bluetoothAdapter?.isEnabled != true) {
                            Log.d(
                                TAG,
                                "Probably failed just because " +
                                    "adapter is disabled!",
                            )
                        }

                        throw NullPointerException(
                            "bluetoothManagerService is null",
                        )
                    }

                    val getAddressMethod =
                        bluetoothManagerService
                            .javaClass
                            .getMethod("getAddress")

                    val value: String? =
                        getAddressMethod
                            .invoke(bluetoothManagerService)
                            ?.toString()

                    if (value == null) {
                        throw NullPointerException("getAddress returned null")
                    }

                    result.success(value)

                    return
                } catch (e: Throwable) {
                    // Ignoring failure
                    // (since it isn't critical API for most applications)
                    Log.d(
                        TAG,
                        "Obtaining address using reflection against " +
                            "internal Android code failed",
                    )
                }

                Log.d(
                    TAG,
                    "Trying to look up address by network " +
                        "interfaces - might be invalid on some devices",
                )

                try {
                    // This method might return invalid MAC address
                    // (since Bluetooth might use other address than WiFi).
                    //
                    // TODO: Further testing:
                    //  1) check is while open connection,
                    //  2) check other devices

                    var value: String? = null

                    NetworkInterface
                        .getNetworkInterfaces()
                        .iterator()
                        .forEach {
                            if (it.name.equals("wlan0", ignoreCase = true)
                            ) {
                                value =
                                    it.hardwareAddress
                                        ?.joinToString(":") { byte ->
                                            "%02x".format(byte)
                                        }
                            }
                        }

                    if (value == null) {
                        throw NullPointerException()
                    }

                    result.success(value)

                    return
                } catch (e: Exception) {
                    // Ignoring failure
                    // (since it isn't critical API for most applications)
                    Log.d(
                        TAG,
                        "Looking for address by network " +
                            "interfaces failed",
                    )
                }

                result.success(null)
            }

            "getState" -> {
                result.success(bluetoothAdapter?.state ?: -1)
            }

            "getName" -> {
                if (checkPermissions(Manifest.permission.BLUETOOTH_CONNECT)) {
                    result.success(bluetoothAdapter?.name)
                } else {
                    result.success(null)
                }
            }

            "setName" -> {
                if (checkPermissions(Manifest.permission.BLUETOOTH_CONNECT)) {
                    if (call.hasArgument("name")) {
                        try {
                            result.success(
                                bluetoothAdapter?.setName(
                                    call.argument("name"),
                                ) ?: false,
                            )
                        } catch (e: Exception) {
                            result.error(
                                "invalid_argument",
                                "'name' argument is required to be string",
                                e,
                            )
                        }
                    } else {
                        result.error(
                            "invalid_argument",
                            "argument 'name' not found",
                            null,
                        )
                    }
                } else {
                    result.error(
                        "invalid_permissions",
                        "BLUETOOTH_CONNECT permission is required",
                        null,
                    )
                }
            }

            "isDiscoverable" -> {
                if (checkPermissions(Manifest.permission.BLUETOOTH_SCAN)) {
                    result.success(
                        bluetoothAdapter?.scanMode ==
                            BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE,
                    )
                } else {
                    result.success(false)
                }
            }

            "requestDiscoverable" -> {
                ensurePermissions({ granted ->
                    if (granted) {
                        val intent =
                            Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE)

                        var duration: Int? = null

                        if (call.hasArgument("duration")) {
                            try {
                                duration = call.argument<Int>("duration")
                            } catch (e: ClassCastException) {
                                Log.d(TAG, "Invalid duration argument: $e")
                            }
                        }

                        if (duration != null) {
                            intent.putExtra(
                                BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION,
                                duration,
                            )
                        }

                        pendingResultForActivityResult = result

                        activity.startActivityForResult(
                            intent,
                            REQUEST_DISCOVERABLE_BLUETOOTH,
                        )
                    } else {
                        result.success(-1)
                    }
                })
            }

            "isDiscovering" -> {
                if (checkPermissions(Manifest.permission.BLUETOOTH_SCAN)) {
                    result.success(bluetoothAdapter?.isDiscovering == true)
                } else {
                    result.success(false)
                }
            }

            "startDiscovery" -> {
                ensurePermissions({ granted ->
                    if (granted) {
                        discoveryWrapper.startDiscovery()

                        result.success(true)
                    } else {
                        result.success(false)
                    }
                })
            }

            "stopDiscovery" -> {
                ensurePermissions({ granted ->
                    if (granted) {
                        discoveryWrapper.stopDiscovery()

                        result.success(true)
                    } else {
                        result.success(false)
                    }
                })
            }

            "getDeviceBondState" -> {
                if (!call.hasArgument("address")) {
                    result.error(
                        "invalid_argument",
                        "argument 'address' not found",
                        null,
                    )
                    return
                }

                val address = call.argument<String>("address")

                if (!BluetoothAdapter.checkBluetoothAddress(address)) {
                    result.error(
                        "invalid_argument",
                        "'address' argument is required to be string " +
                            "containing remote MAC address",
                        null,
                    )
                    return
                }

                result.success(
                    bluetoothAdapter?.getRemoteDevice(address)?.bondState ?: -1,
                )
            }

            "getBondedDevices" -> {
                ensurePermissions({ granted ->
                    if (granted) {
                        result.success(
                            bluetoothAdapter?.bondedDevices?.map {
                                mapOf(
                                    "address" to it.address,
                                    "name" to it.name,
                                    "type" to it.type,
                                    "isConnected" to checkIsDeviceConnected(it),
                                    "bondState" to BluetoothDevice.BOND_BONDED,
                                )
                            } ?: emptyMap<String, Any?>(),
                        )
                    } else {
                        result.error(
                            "no_permissions",
                            "discovering other devices requires location " +
                                "access permission",
                            null,
                        )
                    }
                })
            }

            "removeBondedDevice" -> {
                if (!call.hasArgument("address")) {
                    result.error(
                        "invalid_argument",
                        "argument 'address' not found",
                        null,
                    )
                    return
                }

                val address = call.argument<String>("address")

                if (!BluetoothAdapter.checkBluetoothAddress(address)) {
                    result.error(
                        "invalid_argument",
                        "'address' argument is required to be string " +
                            "containing remote MAC address",
                        null,
                    )
                    return
                }

                val device = bluetoothAdapter?.getRemoteDevice(address)

                when (device?.bondState) {
                    BluetoothDevice.BOND_BONDING -> {
                        result.error(
                            "bond_error",
                            "device already bonding",
                            null,
                        )
                    }

                    BluetoothDevice.BOND_NONE -> {
                        result.error(
                            "bond_error",
                            "device already unbonded",
                            null,
                        )
                    }

                    BluetoothDevice.BOND_BONDED -> {
                        try {
                            val method =
                                device.javaClass.getMethod("removeBond")

                            result.success(
                                method
                                    .invoke(device)
                                    ?.toString()
                                    ?.lowercase() == "true",
                            )
                        } catch (t: Throwable) {
                            result.error(
                                "bond_error",
                                "error while unbonding",
                                t,
                            )
                        }
                    }

                    else -> {
                        result.error(
                            "bond_error",
                            "unknown status: ${device?.bondState}",
                            null,
                        )
                    }
                }
            }

            // TODO: bondDevice

            // TODO: pairingRequestHandlingEnable

            // TODO: pairingRequestHandlingDisable

            // TODO: connect

            // TODO: write

            else -> {
                Log.w(TAG, "Unknown method ${call.method}")
                result.notImplemented()
            }
        }
    }
}
