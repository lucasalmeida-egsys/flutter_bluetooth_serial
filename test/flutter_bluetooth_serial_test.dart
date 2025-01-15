import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_method_channel.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBluetoothSerialPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBluetoothSerialPlatform {
  @override
  Future<String?> getPlatformVersion() => Future<String?>.value('42');

  @override
  Future<bool> isAvailable() => Future<bool>.value(true);
}

void main() {
  final FlutterBluetoothSerialPlatform initialPlatform =
      FlutterBluetoothSerialPlatform.instance;

  test('$MethodChannelFlutterBluetoothSerial is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelFlutterBluetoothSerial>());
  });

  test('getPlatformVersion', () async {
    final FlutterBluetoothSerial flutterBluetoothSerialPlugin =
        FlutterBluetoothSerial();

    final MockFlutterBluetoothSerialPlatform fakePlatform =
        MockFlutterBluetoothSerialPlatform();

    FlutterBluetoothSerialPlatform.instance = fakePlatform;

    expect(await flutterBluetoothSerialPlugin.getPlatformVersion(), '42');
  });
}
