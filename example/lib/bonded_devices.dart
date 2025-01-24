// ignore_for_file: document_ignores, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:folly_fields/util/safe_builder.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';

class BondedDevices extends StatefulWidget {
  const BondedDevices({super.key});

  @override
  State<BondedDevices> createState() => _BondedDevicesState();
}

class _BondedDevicesState extends State<BondedDevices> {
  final FlutterBluetoothSerial _flutterBluetoothSerialPlugin =
      FlutterBluetoothSerial();

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bonded Devices'),
        ),
        body: Expanded(
          child: SafeFutureBuilder<List<BluetoothDevice>>(
            future: _flutterBluetoothSerialPlugin.getBondedDevices(),
            builder: (
              final BuildContext context,
              final List<BluetoothDevice> data,
              final _,
            ) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (
                  final BuildContext context,
                  final int index,
                ) {
                  final BluetoothDevice device = data[index];
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: device.isConnected ? Colors.green : Colors.red,
                    ),
                    title: Text(device.name ?? device.address),
                    subtitle: device.name == null ? null : Text(device.address),
                    trailing: IconButton(
                      onPressed: () async {
                        try {
                          final bool removed =
                              await _flutterBluetoothSerialPlugin
                                  .removeBondedDevice(device.address);

                          await FollyDialogs.dialogMessage(
                            context: context,
                            title: 'Remove Bonded Device',
                            message: '$removed',
                          );

                          if (removed) {
                            setState(() {});
                          }
                        } on Exception catch (e, s) {
                          if (kDebugMode) {
                            print(e);
                            print(s);
                          }

                          await FollyDialogs.dialogMessage(
                            context: context,
                            title: 'Error',
                            message: '$e',
                          );
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
