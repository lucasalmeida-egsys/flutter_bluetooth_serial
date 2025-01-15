import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

/// An implementation of [FlutterBluetoothSerialPlatform] that uses method
/// channels.
class MethodChannelFlutterBluetoothSerial
    extends FlutterBluetoothSerialPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('flutter_bluetooth_serial');

  @override
  Future<String?> getPlatformVersion() async {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<bool> isAvailable() async {
    return (await methodChannel.invokeMethod<bool>('isAvailable')) ?? false;
  }
}
