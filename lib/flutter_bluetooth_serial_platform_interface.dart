import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterBluetoothSerialPlatform extends PlatformInterface {
  /// Constructs a FlutterBluetoothSerialPlatform.
  FlutterBluetoothSerialPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBluetoothSerialPlatform _instance =
      MethodChannelFlutterBluetoothSerial();

  /// The default instance of [FlutterBluetoothSerialPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBluetoothSerial].
  static FlutterBluetoothSerialPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBluetoothSerialPlatform] when
  /// they register themselves.
  static set instance(final FlutterBluetoothSerialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }
}
