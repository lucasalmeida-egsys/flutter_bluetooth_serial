package io.github.edufolly.flutter_bluetooth_serial

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

/**
 * @author Eduardo Folly
 */
class BluetoothStateWrapper(
    messenger: BinaryMessenger,
    private val connections: MutableMap<String, BluetoothConnectionWrapper>,
) : BroadcastReceiver(),
    StreamHandler {
    private val stateChannel: EventChannel =
        EventChannel(messenger, "$NAMESPACE/state").also {
            it.setStreamHandler(this)
        }

    private var stateSink: EventSink? = null

    private lateinit var activity: Activity

    fun config(activity: Activity) {
        this.activity = activity
    }

    fun close() {
        stateChannel.setStreamHandler(null)
    }

    override fun onListen(
        obj: Any?,
        eventSink: EventSink?,
    ) {
        Log.d(TAG, "Listening to bluetooth state changes.")

        stateSink = eventSink

        activity.applicationContext.registerReceiver(
            this,
            IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED),
        )
    }

    override fun onCancel(obj: Any?) {
        Log.d(TAG, "Canceling listening to bluetooth state changes.")

        try {
            activity.applicationContext.unregisterReceiver(this)
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        // TODO: Check if necessary.
        //  stateSink?.endOfStream()
        stateSink = null
    }

    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        if (stateSink == null) return

        when (intent.action) {
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                Log.w(TAG, "Clear All Connections!!")
                connections.values.forEach { it.disconnect() }
                connections.clear()

                stateSink?.success(
                    intent.getIntExtra(
                        BluetoothAdapter.EXTRA_STATE,
                        BluetoothDevice.ERROR,
                    ),
                )
            }

            else -> {
                Log.w(TAG, "Unknown bluetooth state received! ${intent.action}")
            }
        }
    }
}
