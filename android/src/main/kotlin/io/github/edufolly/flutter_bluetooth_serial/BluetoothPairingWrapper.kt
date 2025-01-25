package io.github.edufolly.flutter_bluetooth_serial

import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/**
 * @author Eduardo Folly
 */
class BluetoothPairingWrapper : BroadcastReceiver() {
    private lateinit var activity: Activity
    private lateinit var methodChannel: MethodChannel

    fun config(
        activity: Activity,
        methodChannel: MethodChannel,
    ) {
        this.activity = activity
        this.methodChannel = methodChannel
    }

    fun close() {
    }

    @SuppressLint("MissingPermission")
    @Suppress("DEPRECATION")
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        when (intent.action) {
            BluetoothDevice.ACTION_PAIRING_REQUEST -> {
                val device =
                    intent.getParcelableExtra<BluetoothDevice>(
                        BluetoothDevice.EXTRA_DEVICE,
                    )

                val variant =
                    intent.getIntExtra(
                        BluetoothDevice.EXTRA_PAIRING_VARIANT,
                        BluetoothDevice.ERROR,
                    )

                val key =
                    intent.getIntExtra(
                        BluetoothDevice.EXTRA_PAIRING_KEY,
                        BluetoothDevice.ERROR,
                    )

                val arguments: Map<String, Any?> =
                    mapOf(
                        "address" to device?.address,
                        "variant" to variant,
                        "key" to key,
                    )

                Log.d(TAG, "Paring request? $arguments")

                when (variant) {
                    // Simplest method - 4 digits number
                    BluetoothDevice.PAIRING_VARIANT_PIN -> {
                        val broadcastResult = this.goAsync()

                        methodChannel.invokeMethod(
                            "handlePairingRequest",
                            arguments,
                            InternalResult { result ->
                                Log.d(TAG, "pairingVariantPin: $result")

                                if (result is String) {
                                    try {
                                        Log.d(
                                            TAG,
                                            "Trying to se passkey for " +
                                                "pairing to $result",
                                        )
                                        device?.setPin(result.toByteArray())
                                        broadcastResult.abortBroadcast()
                                    } catch (t: Throwable) {
                                        Log.e(TAG, "pairing_error", t)
                                        // Passing the error
                                        // result.error("bond_error",
                                        // "Setting passkey for pairing failed",
                                        // exceptionToString(ex));
                                    }
                                } else {
                                    Log.d(TAG, "Manual pin pairing in progress")
                                    // Intent intent = new Intent(BluetoothAdapter.ACTION_PAIRING_REQUEST);
                                    // intent.putExtra(BluetoothDevice.EXTRA_DEVICE, device);
                                    // intent.putExtra(BluetoothDevice.EXTRA_PAIRING_VARIANT, pairingVariant)
                                    activity.startActivity(intent)
                                }

                                broadcastResult.finish()
                            },
                        )
                    }

                    // Note: `BluetoothDevice.PAIRING_VARIANT_PASSKEY` seems to
                    // be unsupported anyway... Probably is abandoned.

                    // Displayed passkey on the other device should be the same
                    // as received here.
                    BluetoothDevice.PAIRING_VARIANT_PASSKEY_CONFIRMATION,
                    // 3, // BluetoothDevice.PAIRING_VARIANT_CONSENT
                    -> {
                        // The simplest, but much less secure method - just
                        // yes or no, without any auth. Consent type can use
                        // same code as passkey confirmation since passed
                        // passkey, which is 0 or error at the moment, should
                        // not be used anyway by common code.
                        val broadcastResult = this.goAsync()

                        methodChannel.invokeMethod(
                            "handlePairingRequest",
                            arguments,
                            InternalResult { result ->
                                Log.d(
                                    TAG,
                                    "pairingVariantConfirmation: $result",
                                )

                                if (result is Boolean) {
                                    Log.d(
                                        TAG,
                                        "Trying to set pairing confirmation " +
                                            "to $result (key: $key)",
                                    )
                                    device?.setPairingConfirmation(result)
                                    broadcastResult.abortBroadcast()
                                } else {
                                    Log.d(
                                        TAG,
                                        "Manual passkey confirmation pairing " +
                                            "in progress (key: $key )",
                                    )
                                    activity.startActivity(intent)
                                }

                                broadcastResult.finish()
                            },
                        )
                    }

                    4, // `BluetoothDevice.PAIRING_VARIANT_DISPLAY_PASSKEY`
                    // This pairing method requires to enter the generated and
                    // displayed pairing key on the remote device. It looks
                    // like basic asymmetric cryptography was used.
                    //
                    5, // `BluetoothDevice.PAIRING_VARIANT_DISPLAY_PIN`
                    // Same as previous, but for 4 digit pin.
                    -> {
                        methodChannel.invokeMethod(
                            "handlePairingRequest",
                            arguments,
                        )
                    }

                    // Note: `BluetoothDevice.PAIRING_VARIANT_OOB_CONSENT`
                    // seems to be unsupported for now, at least at master
                    // branch of Android.

                    // Note: `BluetoothDevice.PAIRING_VARIANT_PIN_16_DIGITS `
                    // seems to be unsupported for now, at least at master
                    // branch of Android.

                    else -> {
                        Log.w(TAG, "Unknown pairing variant: $variant")
                    }
                }
            }
        }
    }

    private class InternalResult(
        val onSuccess: (handlerResult: Any?) -> Unit,
    ) : Result {
        override fun success(p0: Any?) {
            onSuccess(p0)
        }

        override fun notImplemented(): Unit =
            throw UnsupportedOperationException()

        override fun error(
            code: String,
            message: String?,
            details: Any?,
        ) {
            Log.d(TAG, "Code: $code - Message: $message, Details: $details")
            throw UnsupportedOperationException()
        }
    }
}
