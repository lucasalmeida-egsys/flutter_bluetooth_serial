// ignore_for_file: document_ignores, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_state.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isAvailable = false;
  bool _isEnabled = false;
  BluetoothState _state = BluetoothState.unknown;
  String? _name;
  String? _address;
  bool _isDiscoverable = false;

  final FlutterBluetoothSerial _flutterBluetoothSerialPlugin =
      FlutterBluetoothSerial();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState({final bool force = false}) async {
    final bool isAvailable = await _flutterBluetoothSerialPlugin.isAvailable();

    final bool isEnabled = await _flutterBluetoothSerialPlugin.isEnabled();

    final BluetoothState state = await _flutterBluetoothSerialPlugin.getState();

    final String? name = await _flutterBluetoothSerialPlugin.getName();

    String? address;

    if (force) {
      // Doesn't work on my phone.
      address = await _flutterBluetoothSerialPlugin.getAddress();
    }

    final bool isDiscoverable =
        await _flutterBluetoothSerialPlugin.isDiscoverable();

    if (!mounted) {
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _isEnabled = isEnabled;
      _address = address;
      _state = state;
      _name = name;
      _isDiscoverable = isDiscoverable;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Bluetooth Serial'),
          actions: <Widget>[
            IconButton(
              onPressed: () => initPlatformState(force: true),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Available
              Text('Available: $_isAvailable'),

              // Enabled
              Text('Enabled: $_isEnabled'),

              // Address
              Text('Address: $_address'),

              // State
              Text('State: $_state'),

              // State Stream
              StreamBuilder<BluetoothState>(
                initialData: _state,
                stream: _flutterBluetoothSerialPlugin.onStateChanged(),
                builder: (
                  final BuildContext context,
                  final AsyncSnapshot<BluetoothState> snapshot,
                ) {
                  if (snapshot.hasData) {
                    return Text('State Stream: ${snapshot.data}');
                  }

                  return const Text('State Stream: Unknown!!');
                },
              ),

              // Name
              Text('Name: $_name'),

              // Discoverable
              Text('Discoverable: $_isDiscoverable'),

              // Open Settings
              ElevatedButton(
                onPressed: _flutterBluetoothSerialPlugin.openSettings,
                child: const Text('Open Settings'),
              ),

              // Request Enable
              ElevatedButton(
                onPressed: () async {
                  final bool enabled =
                      await _flutterBluetoothSerialPlugin.requestEnable();

                  await FollyDialogs.dialogMessage(
                    context: context,
                    title: 'Request Enable',
                    message: '$enabled',
                  );

                  await initPlatformState();
                },
                child: const Text('Request Enable'),
              ),

              // Request Disable
              ElevatedButton(
                onPressed: () async {
                  final bool disabled =
                      await _flutterBluetoothSerialPlugin.requestDisable();

                  await FollyDialogs.dialogMessage(
                    context: context,
                    title: 'Request Disable',
                    message: '$disabled',
                  );

                  await initPlatformState();
                },
                child: const Text('Request Disable'),
              ),

              // Ensure Permissions
              ElevatedButton(
                onPressed: () async {
                  final bool ensurePermissions =
                      await _flutterBluetoothSerialPlugin.ensurePermissions();

                  await FollyDialogs.dialogMessage(
                    context: context,
                    title: 'Ensure Permissions',
                    message: '$ensurePermissions',
                  );

                  await initPlatformState();
                },
                child: const Text('Ensure Permissions'),
              ),

              // Set Name
              ElevatedButton(
                onPressed: () async {
                  final String name = await FollyDialogs.dialogText(
                    context: context,
                    title: 'Set Name',
                    message: 'Set device name',
                    cancelLabel: 'Cancel',
                  );

                  final bool setName =
                      await _flutterBluetoothSerialPlugin.setName(name);

                  await FollyDialogs.dialogMessage(
                    context: context,
                    title: 'Set Name',
                    message: '$setName',
                  );

                  await initPlatformState();
                },
                child: const Text('Set Name'),
              ),

              // Request Discoverable
              ElevatedButton(
                onPressed: () async {
                  // TODO(anyone): Send duration in seconds.
                  // final String name = await FollyDialogs.dialogText(
                  //   context: context,
                  //   title: 'Set Name',
                  //   message: 'Set device name',
                  //   cancelLabel: 'Cancel',
                  // );

                  final int? discoverableTime =
                      await _flutterBluetoothSerialPlugin.requestDiscoverable();

                  await FollyDialogs.dialogMessage(
                    context: context,
                    title: 'Request Discoverable',
                    message: 'Discoverable Time: $discoverableTime',
                  );

                  await initPlatformState();
                },
                child: const Text('Request Discoverable'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
