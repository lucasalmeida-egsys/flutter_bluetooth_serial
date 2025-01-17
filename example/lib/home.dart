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

  final FlutterBluetoothSerial _flutterBluetoothSerialPlugin =
      FlutterBluetoothSerial();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final bool isAvailable = await _flutterBluetoothSerialPlugin.isAvailable();

    final bool isEnabled = await _flutterBluetoothSerialPlugin.isEnabled();

    final String? address = await _flutterBluetoothSerialPlugin.getAddress();

    final BluetoothState state = await _flutterBluetoothSerialPlugin.getState();

    final String? name = await _flutterBluetoothSerialPlugin.getName();

    if (!mounted) {
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _isEnabled = isEnabled;
      _address = address;
      _state = state;
      _name = name;
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
              onPressed: initPlatformState,
              icon: const Icon(Icons.refresh),
            )
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

              // Name
              Text('Name: $_name'),

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
            ],
          ),
        ),
      ),
    );
  }
}
