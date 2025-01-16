import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

class FlutterBluetoothSerial {
  Future<bool> isAvailable() =>
      FlutterBluetoothSerialPlatform.instance.isAvailable();

  Future<bool> isEnabled() =>
      FlutterBluetoothSerialPlatform.instance.isEnabled();

  Future<void> openSettings() =>
      FlutterBluetoothSerialPlatform.instance.openSettings();
}
