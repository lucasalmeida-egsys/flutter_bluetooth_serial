package io.github.edufolly.flutter_bluetooth_serial

import android.bluetooth.BluetoothManager
import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

const val TAG = "FlutterBluetoothPlugin"
const val NAMESPACE = "flutter_bluetooth_serial"

/**
 * @author Eduardo Folly
 */
class FlutterBluetoothSerialPlugin :
    FlutterPlugin,
    ActivityAware {
    // Connections
    // Contains all active connections.
    // Maps ID of the connection with plugin data channels.
    private val connections = mutableSetOf<BluetoothConnection>()

    private lateinit var methodsWrapper: BluetoothMethodsWrapper
    private lateinit var stateWrapper: BluetoothStateWrapper

    override fun onAttachedToEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        Log.v("FlutterBluetoothSerial", "Attached to engine!")

        val messenger = flutterPluginBinding.binaryMessenger

        methodsWrapper = BluetoothMethodsWrapper(messenger)

        stateWrapper =
            BluetoothStateWrapper(
                messenger,
                clearAllConnections = {
                    Log.w(TAG, "Clear All Connections!!")
                    connections.forEach { it.disconnect() }
                    connections.clear()
                },
            )
    }

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding,
    ) {
        stateWrapper.close()

        methodsWrapper.close()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val activity = binding.activity

        val manager =
            activity.getSystemService(
                Context.BLUETOOTH_SERVICE,
            ) as BluetoothManager?

        val bluetoothAdapter = manager?.adapter

        methodsWrapper.config(activity, bluetoothAdapter)

        stateWrapper.config(activity)

        binding.addActivityResultListener(methodsWrapper)

        binding.addRequestPermissionsResultListener(methodsWrapper)
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
