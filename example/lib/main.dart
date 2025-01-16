import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAvailable = false;
  bool _isEnabled = false;

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

    if (!mounted) {
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _isEnabled = isEnabled;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Bluetooth Serial'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Bluetooth available: $_isAvailable'),
                Text('Bluetooth enabled: $_isEnabled'),
                ElevatedButton(
                  onPressed: _flutterBluetoothSerialPlugin.openSettings,
                  child: const Text('Open Settings'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
