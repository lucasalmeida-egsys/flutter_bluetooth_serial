package io.github.edufolly.flutter_bluetooth_serial

import android.bluetooth.BluetoothSocket
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

/**
 * @author Eduardo Folly
 */
class BluetoothConnectionThread(
    private val socket: BluetoothSocket,
    private val onRead: (data: ByteArray) -> Unit,
    private val onDisconnected: (byRemote: Boolean) -> Unit,
) : Thread() {
    private var input: InputStream = socket.inputStream
    private var output: OutputStream = socket.outputStream
    private var requestedClosing = false

    fun isRequestedClosing(): Boolean = requestedClosing

    override fun run() {
        val buffer = ByteArray(1024)
        var bytes: Int

        while (!requestedClosing) {
            try {
                bytes = input.read(buffer)
                if (bytes > 0) {
                    onRead(buffer.copyOfRange(0, bytes))
                }
            } catch (e: IOException) {
                // `input.read` throws when closed by remote device.
                break
            }

            try {
                output.close()
            } catch (t: Throwable) {
                // Ignore any kind of Throwable.
            }

            try {
                input.close()
            } catch (t: Throwable) {
                // Ignore any kind of Throwable.
            }

            // TODO: Socket still open?

            // Callback on disconnected, with information which side is closing.
            onDisconnected(!requestedClosing)

            // Just prevent unnecessary `cancel`ing.
            requestedClosing = true
        }
    }

    fun write(bytes: ByteArray) {
        // TODO: Really need to catch exceptions?
        output.write(bytes)
    }

    fun cancel() {
        if (requestedClosing) return

        requestedClosing = true

        // Flush output buffers before closing.
        try {
            output.flush()
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        // Close the connection socket.
        // Might be useful (see https://stackoverflow.com/a/22769260/4880243)
        try {
            sleep(111)
            socket.close()
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        // TODO: Need to call onDisconnected?
    }
}
