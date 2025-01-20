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
  Future<String> getAddress() => Future<String>.value('00:00:00:00:00:00');

  @override
  Future<BluetoothState> getState() =>
      Future<BluetoothState>.value(BluetoothState.on);

  @override
  Future<String> getName() => Future<String>.value('mock');

  @override
  Future<bool> setName(final String name) => Future<bool>.value(true);
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
}
