package io.github.edufolly.flutter_bluetooth_serial

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

const val TAG = "FlutterBluetoothPlugin"
const val NAMESPACE = "flutter_bluetooth_serial"

fun checkIsDeviceConnected(device: BluetoothDevice?): Boolean =
    try {
        device
            ?.javaClass
            ?.getMethod("isConnected")
            ?.invoke(device)
            ?.toString()
            ?.lowercase() == "true"
    } catch (t: Throwable) {
        false
    }

/**
 * @author Eduardo Folly
 */
class FlutterBluetoothSerialPlugin :
    FlutterPlugin,
    ActivityAware {
    private val connections = mutableMapOf<String, BluetoothConnectionWrapper>()

    private lateinit var discoveryWrapper: BluetoothDiscoveryWrapper
    private lateinit var stateWrapper: BluetoothStateWrapper
    private lateinit var methodsWrapper: BluetoothMethodsWrapper

    override fun onAttachedToEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        Log.v("FlutterBluetoothSerial", "Attached to engine!")

        val messenger = flutterPluginBinding.binaryMessenger

        discoveryWrapper = BluetoothDiscoveryWrapper(messenger)

        stateWrapper = BluetoothStateWrapper(messenger, connections)

        methodsWrapper = BluetoothMethodsWrapper(messenger, connections)
    }

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding,
    ) {
        discoveryWrapper.close()

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

        discoveryWrapper.config(activity, bluetoothAdapter)

        stateWrapper.config(activity)

        methodsWrapper.config(activity, discoveryWrapper, bluetoothAdapter)

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
