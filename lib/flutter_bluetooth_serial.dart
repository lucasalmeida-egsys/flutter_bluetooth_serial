import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

class FlutterBluetoothSerial {
  Future<String?> getPlatformVersion() {
    return FlutterBluetoothSerialPlatform.instance.getPlatformVersion();
  }

  Future<bool> isAvailable() {
    return FlutterBluetoothSerialPlatform.instance.isAvailable();
  }
}
