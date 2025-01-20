import 'package:flutter_bluetooth_serial/bluetooth_state.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

class FlutterBluetoothSerial {
  Stream<BluetoothState> onStateChanged() =>
      FlutterBluetoothSerialPlatform.instance.onStateChanged();

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
}
