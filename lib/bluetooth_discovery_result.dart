import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';

@immutable
class BluetoothDiscoveryResult extends BluetoothDevice {
  final int rssi;

  const BluetoothDiscoveryResult({
    required super.address,
    super.name,
    super.type,
    super.isConnected,
    super.bondState,
    this.rssi = 0,
  });

  BluetoothDiscoveryResult.fromMap(super.map)
      : rssi = int.tryParse(map['rssi'].toString()) ?? 0,
        super.fromMap();

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        ...super.toMap(),
        'rssi': rssi,
      };
}
