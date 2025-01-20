import 'package:flutter_bluetooth_serial/bluetooth_state.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterBluetoothSerialPlatform extends PlatformInterface {
  FlutterBluetoothSerialPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBluetoothSerialPlatform _instance =
      MethodChannelFlutterBluetoothSerial();

  static FlutterBluetoothSerialPlatform get instance => _instance;

  static set instance(final FlutterBluetoothSerialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<BluetoothState> onStateChanged() {
    throw UnimplementedError('onStateChanged() has not been implemented.');
  }

  Future<bool> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }

  Future<bool> isEnabled() {
    throw UnimplementedError('isEnabled() has not been implemented.');
  }

  Future<void> openSettings() {
    throw UnimplementedError('openSettings() has not been implemented.');
  }

  Future<bool> requestEnable() {
    throw UnimplementedError('requestEnable() has not been implemented.');
  }

  Future<bool> requestDisable() {
    throw UnimplementedError('requestDisable() has not been implemented.');
  }

  Future<bool> ensurePermissions() {
    throw UnimplementedError('ensurePermissions() has not been implemented.');
  }

  Future<String?> getAddress() {
    throw UnimplementedError('getAddress() has not been implemented.');
  }

  Future<BluetoothState> getState() {
    throw UnimplementedError('getState() has not been implemented.');
  }

  Future<String?> getName() {
    throw UnimplementedError('getName() has not been implemented.');
  }

  Future<bool> setName(final String name) {
    throw UnimplementedError('setName() has not been implemented.');
  }
}
