import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelFlutterBluetoothSerial platform =
      MethodChannelFlutterBluetoothSerial();

  const MethodChannel channel = MethodChannel('flutter_bluetooth_serial');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (final MethodCall methodCall) async {
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isAvailable', () async {
    expect(await platform.isAvailable(), true);
  });

  // TODO(anyone): isEnabled

  // TODO(anyone): openSettings

  // TODO(anyone): requestEnable

  // TODO(anyone): requestDisable
}
