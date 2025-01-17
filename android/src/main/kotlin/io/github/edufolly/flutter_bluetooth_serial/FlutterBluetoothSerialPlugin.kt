package io.github.edufolly.flutter_bluetooth_serial

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.NetworkInterface

// Permissions and request constants
const val REQUEST_BLUETOOTH_PERMISSIONS: Int = 1451
const val REQUEST_BLUETOOTH: Int = 1337
const val REQUEST_DISCOVERABLE_BLUETOOTH: Int = 2137
const val BLUETOOTH_REQUEST_DISABLE: String =
    "android.bluetooth.adapter.action.REQUEST_DISABLE"
const val TAG = "FlutterBluetoothPlugin"
const val NAMESPACE = "flutter_bluetooth_serial"

/** FlutterBluetoothSerialPlugin */
class FlutterBluetoothSerialPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    // Plugin
    private lateinit var channel: MethodChannel
    private var pendingResultForActivityResult: Result? = null
    private var pendingPermissionsEnsureCallback: ((Boolean) -> Unit)? = null

    // General Bluetooth
    private var bluetoothAdapter: BluetoothAdapter? = null

    private lateinit var activity: Activity
    private lateinit var context: Context

    private fun getBluetoothPermissionName(): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            "nearby devices"
        } else {
            "location"
        }

    private fun checkPermissions(permissions: Array<String>): Boolean =
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

        if (!checkPermissions(permissions)) {
            pendingPermissionsEnsureCallback = callback

            activity.requestPermissions(
                permissions,
                REQUEST_BLUETOOTH_PERMISSIONS,
            )

            return
        }

        callback(true)
    }

    override fun onAttachedToEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        Log.v("FlutterBluetoothSerial", "Attached to engine")
        channel =
            MethodChannel(
                flutterPluginBinding.binaryMessenger,
                "flutter_bluetooth_serial",
            )
        channel.setMethodCallHandler(this)
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
                            context.contentResolver,
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
                result.success(bluetoothAdapter?.name)
            }

            "setName" -> {
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
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding,
    ) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        this.context = binding.activity.applicationContext

        val manager =
            activity.getSystemService(
                Context.BLUETOOTH_SERVICE,
            ) as BluetoothManager?

        bluetoothAdapter = manager?.adapter

        binding.addActivityResultListener { requestCode, resultCode, _ ->
            when (requestCode) {
                REQUEST_BLUETOOTH -> {
                    pendingResultForActivityResult?.success(resultCode != 0)
                    true
                }

//                REQUEST_DISCOVERABLE_BLUETOOTH -> {
//                    pendingResultForActivityResult?.success(
//                        // TODO: This if is really necessary?
//                        if (resultCode == 0) {
//                            -1
//                        } else {
//                            resultCode
//                        },
//                    )
//                    true
//                }

                else -> {
                    false
                }
            }
        }

        binding.addRequestPermissionsResultListener {
            requestCode,
            _,
            grantResults,
            ->
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
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding,
    ) {
    }

    override fun onDetachedFromActivity() {
    }
}
