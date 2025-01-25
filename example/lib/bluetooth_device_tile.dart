import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';

class BluetoothDeviceTile extends StatelessWidget {
  final BluetoothDevice device;

  final Future<bool> Function(BluetoothDevice device)? bondDevice;
  final Future<bool> Function(BluetoothDevice device) removeBondedDevice;

  const BluetoothDeviceTile(
    this.device, {
    required this.removeBondedDevice,
    this.bondDevice,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        foregroundColor: Colors.white,
        backgroundColor: device.isConnected
            ? Colors.green
            : switch (device.bondState) {
                BluetoothBondState.none => Colors.red,
                BluetoothBondState.bonding => Colors.amber,
                BluetoothBondState.bonded => Colors.blue,
                BluetoothBondState.error => Colors.purple,
                BluetoothBondState.unknown => Colors.deepPurple,
              },
        child: Text(
          device is BluetoothDiscoveryResult
              ? '${(device as BluetoothDiscoveryResult).rssi}'
              : '',
        ),
      ),
      title: Text(device.name ?? device.address),
      subtitle: device.name == null ? null : Text(device.address),
      trailing: !device.isBonded && bondDevice == null
          ? null
          : IconButton(
              onPressed: () async {
                final String title =
                    device.isBonded ? 'Remove Bonded Device' : 'Bond Device';

                try {
                  final bool result = device.isBonded
                      ? await removeBondedDevice(device)
                      : await bondDevice!(device);

                  await FollyDialogs.dialogMessage(
                    context: context,
                    title: title,
                    message: '$result',
                  );
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
              icon: Icon(device.isBonded ? Icons.delete : Icons.add),
            ),
    );
  }
}
