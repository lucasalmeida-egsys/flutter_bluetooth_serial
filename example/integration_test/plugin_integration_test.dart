import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isAvailable test', (final WidgetTester tester) async {
    final FlutterBluetoothSerial plugin = FlutterBluetoothSerial();
    final bool isAvailable = await plugin.isAvailable();
    expect(isAvailable, true);
  });

  // TODO(anyone): isEnabled

  // TODO(anyone): openSettings
}
