import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_request.dart';
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

  Stream<BluetoothDiscoveryResult> onDiscovery() {
    throw UnimplementedError('onDiscovery() has not been implemented.');
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

  Future<String?> get address {
    throw UnimplementedError('get address has not been implemented.');
  }

  Future<BluetoothState> get state {
    throw UnimplementedError('get state has not been implemented.');
  }

  Future<String?> get name {
    throw UnimplementedError('get name has not been implemented.');
  }

  Future<bool> setName(final String name) {
    throw UnimplementedError('setName() has not been implemented.');
  }

  Future<bool> isDiscoverable() {
    throw UnimplementedError('isDiscoverable() has not been implemented.');
  }

  Future<int?> requestDiscoverable({final int? durationInSeconds}) {
    throw UnimplementedError('requestDiscoverable() has not been implemented.');
  }

  Future<bool> isDiscovering() {
    throw UnimplementedError('isDiscovering() has not been implemented.');
  }

  Future<bool> startDiscovery() {
    throw UnimplementedError('startDiscovery() has not been implemented.');
  }

  Future<bool> stopDiscovery() {
    throw UnimplementedError('stopDiscovery() has not been implemented.');
  }

  Future<BluetoothBondState> getDeviceBondState(final String address) {
    throw UnimplementedError('getDeviceBondState() has not been implemented.');
  }

  Future<List<BluetoothDevice>> getBondedDevices() {
    throw UnimplementedError('getBondedDevices() has not been implemented.');
  }

  Future<bool> removeBondedDevice(final String address) {
    throw UnimplementedError('removeBondedDevice() has not been implemented.');
  }

  void setPairingRequestHandler(
    final Future<dynamic> Function(BluetoothPairingRequest request)? handler,
  ) {
    throw UnimplementedError(
      'setPairingRequestHandler() has not been implemented.',
    );
  }

  Future<bool> bondDevice(
    final String address, {
    final String? pin,
    final bool? passkeyConfirm,
  }) {
    throw UnimplementedError('bondDevice() has not been implemented.');
  }
}
