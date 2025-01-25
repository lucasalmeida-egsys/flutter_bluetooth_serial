import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_request.dart';
import 'package:flutter_bluetooth_serial/bluetooth_state.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_method_channel.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBluetoothSerialPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBluetoothSerialPlatform {
  @override
  Stream<BluetoothState> onStateChanged() =>
      Stream<BluetoothState>.value(BluetoothState.on);

  @override
  Stream<BluetoothDiscoveryResult> onDiscovery() =>
      Stream<BluetoothDiscoveryResult>.value(
        const BluetoothDiscoveryResult(address: '00:00:00:00:00:00'),
      );

  @override
  Future<bool> isAvailable() => Future<bool>.value(true);

  @override
  Future<bool> isEnabled() => Future<bool>.value(true);

  @override
  Future<void> openSettings() => Future<void>.value();

  @override
  Future<bool> requestEnable() => Future<bool>.value(true);

  @override
  Future<bool> requestDisable() => Future<bool>.value(true);

  @override
  Future<bool> ensurePermissions() => Future<bool>.value(true);

  @override
  Future<String> get address => Future<String>.value('00:00:00:00:00:00');

  @override
  Future<BluetoothState> get state =>
      Future<BluetoothState>.value(BluetoothState.on);

  @override
  Future<String> get name => Future<String>.value('mock');

  @override
  Future<bool> setName(final String name) => Future<bool>.value(true);

  @override
  Future<bool> isDiscoverable() => Future<bool>.value(true);

  @override
  Future<int?> requestDiscoverable({final int? durationInSeconds}) =>
      Future<int?>.value(180);

  @override
  Future<bool> isDiscovering() => Future<bool>.value(false);

  @override
  Future<bool> startDiscovery() => Future<bool>.value(true);

  @override
  Future<bool> stopDiscovery() => Future<bool>.value(true);

  @override
  Future<BluetoothBondState> getDeviceBondState(final String address) =>
      Future<BluetoothBondState>.value(BluetoothBondState.none);

  @override
  Future<List<BluetoothDevice>> getBondedDevices() =>
      Future<List<BluetoothDevice>>.value(
        <BluetoothDevice>[
          const BluetoothDevice(address: '00:00:00:00:00:00'),
        ],
      );

  @override
  Future<bool> removeBondedDevice(final String address) =>
      Future<bool>.value(true);

  @override
  void setPairingRequestHandler(
    final Future<dynamic> Function(BluetoothPairingRequest request)? handler,
  ) {}

  @override
  Future<bool> bondDevice(
    final String address, {
    final String? pin,
    final bool? passkeyConfirm,
  }) =>
      Future<bool>.value(true);
}

void main() {
  final FlutterBluetoothSerialPlatform initialPlatform =
      FlutterBluetoothSerialPlatform.instance;

  test('$MethodChannelFlutterBluetoothSerial is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterBluetoothSerial>(),
    );
  });

  // TODO(anyone): onStateChanged

  // TODO(anyone): onDiscovery

  test('isAvailable', () async {
    final FlutterBluetoothSerial flutterBluetoothSerialPlugin =
        FlutterBluetoothSerial();

    final MockFlutterBluetoothSerialPlatform fakePlatform =
        MockFlutterBluetoothSerialPlatform();

    FlutterBluetoothSerialPlatform.instance = fakePlatform;

    expect(await flutterBluetoothSerialPlugin.isAvailable(), true);
  });

  // TODO(anyone): isEnabled

  // TODO(anyone): openSettings

  // TODO(anyone): requestEnable

  // TODO(anyone): requestDisable

  // TODO(anyone): ensurePermissions

  // TODO(anyone): getAddress

  // TODO(anyone): getState

  // TODO(anyone): getName

  // TODO(anyone): setName

  // TODO(anyone): isDiscoverable

  // TODO(anyone): requestDiscoverable

  // TODO(anyone): isDiscovering

  // TODO(anyone): startDiscovery

  // TODO(anyone): stopDiscovery

  // TODO(anyone): getDeviceBondState

  // TODO(anyone): removeBondedDevice

  // TODO(anyone): setPairingRequestHandler

  // TODO(anyone): bondDevice
}
