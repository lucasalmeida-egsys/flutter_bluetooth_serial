import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/bluetooth_device_tile.dart';

class DiscoveryDevices extends StatefulWidget {
  const DiscoveryDevices({super.key});

  @override
  State<DiscoveryDevices> createState() => _DiscoveryDevicesState();
}

class _DiscoveryDevicesState extends State<DiscoveryDevices> {
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];

  bool _isDiscovering = false;

  final FlutterBluetoothSerial _flutterBluetoothSerialPlugin =
      FlutterBluetoothSerial();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final bool isDiscovering =
        await _flutterBluetoothSerialPlugin.isDiscovering();

    if (!mounted) {
      return;
    }

    setState(() {
      _isDiscovering = isDiscovering;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Discovery')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Discovering
            Visibility(
              visible: _isDiscovering,
              child: const LinearProgressIndicator(),
            ),

            // Start Discovery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _isDiscovering
                    ? null
                    : () async {
                        await _flutterBluetoothSerialPlugin.startDiscovery();

                        _flutterBluetoothSerialPlugin.onDiscovery().listen(
                              (final BluetoothDiscoveryResult event) {
                                if (results.contains(event)) {
                                  results.remove(event);
                                }

                                setState(() {
                                  results.add(event);
                                });
                              },
                              cancelOnError: true,
                              onError: (final dynamic e, final StackTrace s) {
                                if (kDebugMode) {
                                  print(e);
                                  print(s);
                                }
                                return initPlatformState();
                              },
                              onDone: initPlatformState,
                            );

                        await initPlatformState();
                      },
                child: const Text('Start Discovery'),
              ),
            ),

            // Stop Discovery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: !_isDiscovering
                    ? null
                    : () async {
                        await _flutterBluetoothSerialPlugin.stopDiscovery();

                        await initPlatformState();
                      },
                child: const Text('Stop Discovery'),
              ),
            ),

            // Discovery List
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (final BuildContext context, final int index) {
                  return BluetoothDeviceTile(
                    results[index],
                    bondDevice: (final BluetoothDevice device) async {
                      final bool bonded = await _flutterBluetoothSerialPlugin
                          .bondDevice(device.address);

                      // if (bonded) {
                      //   await initPlatformState();
                      // }

                      return bonded;
                    },
                    removeBondedDevice: (final BluetoothDevice device) async {
                      final bool removed = await _flutterBluetoothSerialPlugin
                          .removeBondedDevice(device.address);

                      if (removed) {
                        results.remove(device);
                        await initPlatformState();
                      }

                      return removed;
                    },
                  );
                },
              ),
            ),

            // Clear Discovery List
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: results.isEmpty
                    ? null
                    : () => setState(() => results.clear()),
                child: const Text('Clear Discovery List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
