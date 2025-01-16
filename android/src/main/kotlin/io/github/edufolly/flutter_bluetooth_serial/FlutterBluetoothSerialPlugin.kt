package io.github.edufolly.flutter_bluetooth_serial

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// Permissions and request constants
const val REQUEST_COARSE_LOCATION_PERMISSIONS: Int = 1451
const val REQUEST_ENABLE_BLUETOOTH: Int = 1337
const val REQUEST_DISCOVERABLE_BLUETOOTH: Int = 2137

/** FlutterBluetoothSerialPlugin */
class FlutterBluetoothSerialPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    // Plugin
    private val tag = "FlutterBluetoothPlugin"
    private val namespace = "flutter_bluetooth_serial"
    private lateinit var channel: MethodChannel
    private var pendingResultForActivityResult: Result? = null

    // General Bluetooth
    private var bluetoothAdapter: BluetoothAdapter? = null

    private lateinit var activity: Activity
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.v("FlutterBluetoothSerial", "Attached to engine")
        channel =
            MethodChannel(
                flutterPluginBinding.binaryMessenger,
                "flutter_bluetooth_serial",
            )
        channel.setMethodCallHandler(this)
    }

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
                activity.startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
                result.success(null)
            }

            "requestEnable" -> {
                if (bluetoothAdapter?.isEnabled == true) {
                    result.success(true)
                } else {
                    pendingResultForActivityResult = result
                    activity.startActivityForResult(
                        Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                        REQUEST_ENABLE_BLUETOOTH,
                    )
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        this.context = binding.activity.applicationContext

        val manager =
            activity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?

        bluetoothAdapter = manager?.adapter

        binding.addActivityResultListener { requestCode, resultCode, _ ->
            when (requestCode) {
                REQUEST_ENABLE_BLUETOOTH -> {
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

                else -> false
            }
        }

        // TODO: addRequestPermissionsResultListener
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
}
