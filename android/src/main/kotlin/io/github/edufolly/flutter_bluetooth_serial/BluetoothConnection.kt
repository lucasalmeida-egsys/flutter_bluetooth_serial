package io.github.edufolly.flutter_bluetooth_serial

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import java.io.IOException
import java.util.UUID

/**
 * Universal Bluetooth serial connection class
 */
abstract class BluetoothConnection(
    private val bluetoothAdapter: BluetoothAdapter,
) {
    companion object {
        val DEFAULT_UUID: UUID =
            UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    }

    abstract fun onRead(data: ByteArray)

    abstract fun onDisconnected(byRemote: Boolean)

    private var connectionThread: BluetoothConnectionThread? = null

    fun isConnected(): Boolean = connectionThread?.isRequestedClosing() ?: false

    // TODO: `connect` could be done performed on the other thread
    // TODO: `connect` parameter: timeout
    // TODO: `connect` other methods than `createRfcommSocketToServiceRecord`,
    //  including hidden one raw `createRfcommSocket` (on channel).
    // TODO: how about turning it into a factory?
    // Connects to given device by hardware address

    @SuppressLint("MissingPermission")
    fun connect(
        address: String,
        uuid: UUID = DEFAULT_UUID,
    ) {
        if (isConnected()) {
            throw IllegalStateException("Already connected")
        }

        val device: BluetoothDevice =
            bluetoothAdapter.getRemoteDevice(address)
                ?: throw IllegalArgumentException("Device not found")

        // TODO: Introduce ConnectionMethod
        val socket: BluetoothSocket =
            device.createRfcommSocketToServiceRecord(uuid)
                ?: throw IOException("Socket connection not established")

        // Cancel discovery, even though we didn't start it
        bluetoothAdapter.cancelDiscovery()

        socket.connect()

        connectionThread =
            BluetoothConnectionThread(
                socket,
                { data -> onRead(data) },
                { byRemote -> onDisconnected(byRemote) },
            ).apply { start() }
    }

    fun disconnect() {
        if (isConnected()) {
            connectionThread?.cancel()
            connectionThread = null
        }
    }

    fun write(bytes: ByteArray) {
        if (!isConnected()) {
            throw IOException("Not connected")
        }

        connectionThread?.write(bytes)
    }
}
