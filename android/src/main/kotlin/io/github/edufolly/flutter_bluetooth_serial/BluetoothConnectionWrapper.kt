package io.github.edufolly.flutter_bluetooth_serial

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.os.AsyncTask
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

/**
 * @author Eduardo Folly
 */
class BluetoothConnectionWrapper(
    adapter: BluetoothAdapter,
    messenger: BinaryMessenger,
    private val activity: Activity,
    private val id: Int,
    private val onClosed: (id: Int) -> Unit,
) : BluetoothConnection(adapter),
    StreamHandler {
    private var readSink: EventSink? = null

    private val readChannel: EventChannel =
        EventChannel(messenger, "$NAMESPACE/read/$id").also {
            it.setStreamHandler(this)
        }

    override fun onListen(
        obj: Any?,
        eventSink: EventSink?,
    ) {
        readSink = eventSink
    }

    override fun onCancel(obj: Any?) {
        // If canceled by local, disconnects,
        // in other case, by remote, does nothing.

        disconnect()

        // True dispose.
        // TODO: Use coroutines!
        AsyncTask.execute {
            readChannel.setStreamHandler(null)
            onClosed(id)

            Log.d(TAG, "Disconnected (id: $id)")
        }
    }

    override fun onRead(data: ByteArray) {
        activity.runOnUiThread {
            readSink?.success(data)
        }
    }

    override fun onDisconnected(byRemote: Boolean) {
        activity.runOnUiThread {
            if (byRemote) {
                Log.d(TAG, "onDisconnected by remote (id: $id)")
                readSink?.endOfStream()
                readSink = null
            } else {
                Log.d(TAG, "onDisconnected by local (id: $id)")
            }
        }
    }
}
