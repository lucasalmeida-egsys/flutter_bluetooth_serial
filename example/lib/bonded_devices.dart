import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/bluetooth_device_tile.dart';
import 'package:flutter_bluetooth_serial_example/connect_device.dart';

import 'package:folly_fields/util/safe_builder.dart';

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
          actions: <Widget>[
            IconButton(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
            ),
          ],
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
                itemBuilder: (final BuildContext context, final int index) {
                  return BluetoothDeviceTile(
                    data[index],
                    onTap: (final BluetoothDevice device) =>
                        Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (final BuildContext context) =>
                            ConnectDevice(device),
                      ),
                    ),
                    removeBondedDevice: (final BluetoothDevice device) async {
                      final bool removed = await _flutterBluetoothSerialPlugin
                          .removeBondedDevice(device.address);

                      if (removed) {
                        setState(() {});
                      }

                      return removed;
                    },
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
