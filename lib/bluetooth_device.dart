import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device_type.dart';

/// Represents information about the device. Could be out-of-date.
// TODO(anyone): Add updating the info via copyWith.
@immutable
class BluetoothDevice {
  /// MAC address of the device or identifier for platform system
  /// (if MAC addresses are prohibited).
  final String address;

  /// Transmitted friendly name of the device.
  final String? name;

  /// Type of the device (Bluetooth standard type).
  final BluetoothDeviceType type;

  /// Describes is device connected.
  final bool isConnected;

  /// Bonding state of the device.
  final BluetoothBondState bondState;

  /// Construct `BluetoothDevice` with given values.
  const BluetoothDevice({
    required this.address,
    this.name,
    this.type = BluetoothDeviceType.unknown,
    this.isConnected = false,
    this.bondState = BluetoothBondState.unknown,
  });

  /// Creates `BluetoothDevice` from map.
  ///
  /// Internally used to receive the object from platform code.
  BluetoothDevice.fromMap(final Map<String, dynamic> map)
      : name = map['name']?.toString(),
        address = map['address']!.toString(),
        type = BluetoothDeviceType.parse(map['type']),
        isConnected = map['isConnected'].toString().toLowerCase() == 'true',
        bondState = BluetoothBondState.parse(map['bondState']);

  /// Creates map from `BluetoothDevice`.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'address': address,
        'type': type.name,
        'isConnected': isConnected,
        'bondState': bondState.name,
      };

  /// Compares for equality of this and other `BluetoothDevice`.
  ///
  /// In fact, only `address` is compared, since this is most important
  /// and immutable information that identifies each device.
  @override
  bool operator ==(final Object other) {
    return other is BluetoothDevice && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;

  /// Tells whether the device is bonded (ready to secure connect).
  bool get isBonded => bondState.isBonded;
}
