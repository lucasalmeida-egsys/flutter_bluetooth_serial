import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String namespace = 'flutter_bluetooth_serial';

  // TODO(anyone): stateChannel

  final MethodChannelFlutterBluetoothSerial platform =
      MethodChannelFlutterBluetoothSerial();

  const MethodChannel channel = MethodChannel('$namespace/methods');

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

  // TODO(anyone): onStateChanged

  test('isAvailable', () async {
    expect(await platform.isAvailable(), true);
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
