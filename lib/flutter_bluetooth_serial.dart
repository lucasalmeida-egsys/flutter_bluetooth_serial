import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_state.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

class FlutterBluetoothSerial {
  Stream<BluetoothState> onStateChanged() =>
      FlutterBluetoothSerialPlatform.instance.onStateChanged();

  Stream<BluetoothDiscoveryResult> onDiscovery() =>
      FlutterBluetoothSerialPlatform.instance.onDiscovery();

  Future<bool> isAvailable() =>
      FlutterBluetoothSerialPlatform.instance.isAvailable();

  Future<bool> isEnabled() =>
      FlutterBluetoothSerialPlatform.instance.isEnabled();

  Future<void> openSettings() =>
      FlutterBluetoothSerialPlatform.instance.openSettings();

  Future<bool> requestEnable() =>
      FlutterBluetoothSerialPlatform.instance.requestEnable();

  Future<bool> requestDisable() =>
      FlutterBluetoothSerialPlatform.instance.requestDisable();

  Future<bool> ensurePermissions() =>
      FlutterBluetoothSerialPlatform.instance.ensurePermissions();

  Future<String?> getAddress() =>
      FlutterBluetoothSerialPlatform.instance.getAddress();

  Future<BluetoothState> getState() =>
      FlutterBluetoothSerialPlatform.instance.getState();

  Future<String?> getName() =>
      FlutterBluetoothSerialPlatform.instance.getName();

  Future<bool> setName(final String name) =>
      FlutterBluetoothSerialPlatform.instance.setName(name);

  Future<bool> isDiscoverable() =>
      FlutterBluetoothSerialPlatform.instance.isDiscoverable();

  Future<int?> requestDiscoverable({final int? durationInSeconds}) =>
      FlutterBluetoothSerialPlatform.instance
          .requestDiscoverable(durationInSeconds: durationInSeconds);

  Future<bool> isDiscovering() =>
      FlutterBluetoothSerialPlatform.instance.isDiscovering();

  Future<bool> startDiscovery() =>
      FlutterBluetoothSerialPlatform.instance.startDiscovery();

  Future<bool> stopDiscovery() =>
      FlutterBluetoothSerialPlatform.instance.stopDiscovery();

  Future<BluetoothBondState> getDeviceBondState(final String address) =>
      FlutterBluetoothSerialPlatform.instance.getDeviceBondState(address);
}
