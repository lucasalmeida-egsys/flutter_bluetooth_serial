// ignore_for_file: document_ignores, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<Discovery> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
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

                        await initPlatformState();

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
                  final BluetoothDiscoveryResult device = results[index];

                  return ListTile(
                    title: Text(device.name ?? device.address),
                    subtitle: device.name == null ? null : Text(device.address),
                    leading: CircleAvatar(
                      child: Text('${device.rssi}'),
                    ),
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
