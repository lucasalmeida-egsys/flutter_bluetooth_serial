import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_request.dart';
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

  Future<String?> get address =>
      FlutterBluetoothSerialPlatform.instance.address;

  Future<BluetoothState> get state =>
      FlutterBluetoothSerialPlatform.instance.state;

  Future<String?> get name => FlutterBluetoothSerialPlatform.instance.name;

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

  Future<List<BluetoothDevice>> getBondedDevices() =>
      FlutterBluetoothSerialPlatform.instance.getBondedDevices();

  Future<bool> removeBondedDevice(final String address) =>
      FlutterBluetoothSerialPlatform.instance.removeBondedDevice(address);

  void setPairingRequestHandler(
    final Future<dynamic> Function(BluetoothPairingRequest request)? handler,
  ) =>
      FlutterBluetoothSerialPlatform.instance.setPairingRequestHandler(handler);

  Future<bool> bondDevice(
    final String address, {
    final String? pin,
    final bool? passkeyConfirm,
  }) =>
      FlutterBluetoothSerialPlatform.instance.bondDevice(
        address,
        pin: pin,
        passkeyConfirm: passkeyConfirm,
      );
}
