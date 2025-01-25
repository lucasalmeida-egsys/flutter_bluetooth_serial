import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_variant.dart';

@immutable
class BluetoothPairingRequest {
  /// MAC address of the device or identifier for platform system
  /// (if MAC addresses are prohibited).
  final String? address;

  /// Variant of the pairing methods.
  final BluetoothPairingVariant variant;

  /// Passkey for confirmation.
  final int? key;

  /// Construct `BluetoothPairingRequest` with given values.
  const BluetoothPairingRequest({
    this.address,
    this.variant = BluetoothPairingVariant.unknown,
    this.key,
  });

  /// Creates `BluetoothPairingRequest` from map.
  /// Internally used to receive the object from platform code.
  BluetoothPairingRequest.fromMap(final Map<dynamic, dynamic> map)
      : address = map['address']?.toString(),
        variant = BluetoothPairingVariant.parse(map['variant']),
        key = int.tryParse(map['key'].toString());
}
