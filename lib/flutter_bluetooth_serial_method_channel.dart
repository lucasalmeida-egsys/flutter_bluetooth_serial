import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_request.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_variant.dart';
import 'package:flutter_bluetooth_serial/bluetooth_state.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

class MethodChannelFlutterBluetoothSerial
    extends FlutterBluetoothSerialPlatform {
  static const String namespace = 'flutter_bluetooth_serial';

  @visibleForTesting
  final EventChannel stateChannel = const EventChannel('$namespace/state');

  /// Allows monitoring the Bluetooth adapter state changes.
  @override
  Stream<BluetoothState> onStateChanged() {
    return stateChannel.receiveBroadcastStream().map(BluetoothState.parse);
  }

  @visibleForTesting
  final EventChannel discoveryChannel =
      const EventChannel('$namespace/discovery');

  /// Receive discovery results.
  @override
  Stream<BluetoothDiscoveryResult> onDiscovery() {
    return discoveryChannel.receiveBroadcastStream().map(
          (final dynamic e) =>
              BluetoothDiscoveryResult.fromMap(e as Map<dynamic, dynamic>),
        );
  }

  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('$namespace/methods');

  /// Function used as pairing request handler.
  Future<dynamic> Function(BluetoothPairingRequest request)?
      _pairingRequestHandler;

  MethodChannelFlutterBluetoothSerial() {
    methodChannel.setMethodCallHandler((final MethodCall call) async {
      switch (call.method) {
        case 'handlePairingRequest':
          if (_pairingRequestHandler != null) {
            return _pairingRequestHandler!(
              BluetoothPairingRequest.fromMap(call.arguments),
            );
          }

        default:
          throw Exception(
            'unknown common code method ${call.method} not implemented',
          );
      }
    });
  }

  /// Checks is the Bluetooth interface available on host device.
  @override
  Future<bool> isAvailable() async =>
      (await methodChannel.invokeMethod<bool>('isAvailable')) ?? false;

  /// Describes is the Bluetooth interface enabled on host device.
  @override
  Future<bool> isEnabled() async =>
      (await methodChannel.invokeMethod<bool>('isEnabled')) ?? false;

  /// Opens the Bluetooth platform system settings.
  @override
  Future<void> openSettings() async =>
      methodChannel.invokeMethod<void>('openSettings');

  /// Tries to enable Bluetooth interface (if disabled).
  /// Probably results in asking user for confirmation.
  @override
  Future<bool> requestEnable() async =>
      (await methodChannel.invokeMethod<bool>('requestEnable')) ?? false;

  /// Tries to disable Bluetooth interface (if enabled).
  @override
  Future<bool> requestDisable() async =>
      (await methodChannel.invokeMethod<bool>('requestDisable')) ?? false;

  @override
  Future<bool> ensurePermissions() async =>
      (await methodChannel.invokeMethod<bool>('ensurePermissions')) ?? false;

  /// Returns the hardware address of the local Bluetooth adapter.
  ///
  /// Does not work for third party applications starting at Android 6.0.
  @override
  Future<String?> get address =>
      methodChannel.invokeMethod<String>('getAddress');

  /// State of the Bluetooth adapter.
  @override
  Future<BluetoothState> get state async => BluetoothState.parse(
        (await methodChannel.invokeMethod<int>('getState')) ?? -2,
      );

  /// Returns the friendly Bluetooth name of the local Bluetooth adapter.
  ///
  /// This name is visible to remote Bluetooth devices.
  ///
  /// Does not work for third party applications starting at Android 6.0.
  @override
  Future<String?> get name => methodChannel.invokeMethod<String>('getName');

  /// Sets the friendly Bluetooth name of the local Bluetooth adapter.
  ///
  /// This name is visible to remote Bluetooth devices.
  ///
  /// Valid Bluetooth names are a maximum of 248 bytes using UTF-8 encoding,
  /// although many remote devices can only display the first 40 characters,
  /// and some may be limited to just 20.
  ///
  /// Does not work for third party applications starting at Android 6.0.
  @override
  Future<bool> setName(final String name) async =>
      (await methodChannel.invokeMethod<bool>(
        'setName',
        <String, dynamic>{'name': name},
      )) ??
      false;

  /// Describes is the local device in discoverable mode.
  @override
  Future<bool> isDiscoverable() async =>
      (await methodChannel.invokeMethod<bool>('isDiscoverable')) ?? false;

  /// Asks for discoverable mode (prompt for user interaction in fact).
  /// Returns number of seconds acquired or -1 if canceled or failed gracefully.
  ///
  /// Duration might be capped to 120, 300 or 3600 seconds on some devices.
  @override
  Future<int?> requestDiscoverable({final int? durationInSeconds}) =>
      methodChannel.invokeMethod<int>(
        'requestDiscoverable',
        durationInSeconds == null
            ? null
            : <String, dynamic>{
                'duration': durationInSeconds,
              },
      );

  /// Describes is the discovery process of Bluetooth devices running.
  @override
  Future<bool> isDiscovering() async =>
      (await methodChannel.invokeMethod<bool>('isDiscovering')) ?? false;

  /// Starts discovery.
  @override
  Future<bool> startDiscovery() async =>
      (await methodChannel.invokeMethod<bool>('startDiscovery')) ?? false;

  /// Stops discovery.
  @override
  Future<bool> stopDiscovery() async =>
      (await methodChannel.invokeMethod<bool>('stopDiscovery')) ?? false;

  /// Checks bond state for given address (might be from system cache).
  @override
  Future<BluetoothBondState> getDeviceBondState(final String address) async =>
      BluetoothBondState.parse(
        await methodChannel.invokeMethod<int>(
          'getDeviceBondState',
          <String, dynamic>{'address': address},
        ),
      );

  /// Returns list of bonded devices.
  @override
  Future<List<BluetoothDevice>> getBondedDevices() async =>
      (await methodChannel.invokeMethod<List<dynamic>>('getBondedDevices'))
          ?.map(
            (final dynamic e) =>
                BluetoothDevice.fromMap(e as Map<dynamic, dynamic>),
          )
          .toList() ??
      <BluetoothDevice>[];

  /// Removes bond with device with specified address.
  /// Returns true if unbonded, false if canceled or failed gracefully.
  ///
  /// Note: May not work at every Android device!
  @override
  Future<bool> removeBondedDevice(final String address) async {
    return (await methodChannel.invokeMethod<bool>(
          'removeBondedDevice',
          <String, dynamic>{'address': address},
        )) ??
        false;
  }

  /// Allows listening and response for incoming pairing requests.
  ///
  /// Various variants of pairing requests might require different returns:
  /// * `PairingVariant.Pin` or `PairingVariant.Pin16Digits`
  /// (prompt to enter a pin)
  ///   - return string containing the pin for pairing
  ///   - return `false` to reject.
  /// * `BluetoothDevice.PasskeyConfirmation`
  /// (user needs to confirm displayed passkey, no rewriting necessary)
  ///   - return `true` to accept, `false` to reject.
  ///   - there is `passkey` parameter available.
  /// * `PairingVariant.Consent`
  /// (just prompt with device name to accept without any code or passkey)
  ///   - return `true` to accept, `false` to reject.
  ///
  /// If returned null, the request will be passed for manual pairing
  /// using default Android Bluetooth settings pairing dialog.
  ///
  /// Note: Accepting request variant of `PasskeyConfirmation` and `Consent`
  /// will probably fail, because it require Android `setPairingConfirmation`
  /// which requires `BLUETOOTH_PRIVILEGED` permission that 3rd party apps
  /// cannot acquire (at least on newest Androids) due to security reasons.
  ///
  /// Note: It is necessary to return from handler within 10 seconds, since
  /// Android BroadcastReceiver can wait safely only up to that duration.
  @override
  void setPairingRequestHandler(
    final Future<dynamic> Function(BluetoothPairingRequest request)? handler,
  ) {
    if (handler == null) {
      _pairingRequestHandler = null;
      methodChannel.invokeMethod('pairingRequestHandlingDisable');
      return;
    }

    if (_pairingRequestHandler == null) {
      methodChannel.invokeMethod('pairingRequestHandlingEnable');
    }

    _pairingRequestHandler = handler;
  }

  /// Starts outgoing bonding (pairing) with device with given address.
  /// Returns true if bonded, false if canceled or failed gracefully.
  ///
  /// `pin` or `passkeyConfirm` could be used to automate the bonding process,
  /// using provided pin or confirmation if necessary. Can be used only if no
  /// pairing request handler is already registered.
  ///
  /// Note: `passkeyConfirm` will probably not work, since 3rd party apps cannot
  /// get `BLUETOOTH_PRIVILEGED` permission (at least on newest Androids).
  @override
  Future<bool> bondDevice(
    final String address, {
    final String? pin,
    final bool? passkeyConfirm,
  }) async {
    if (pin != null || passkeyConfirm != null) {
      if (_pairingRequestHandler != null) {
        throw Exception('pairing request handler already registered');
      }

      setPairingRequestHandler((final BluetoothPairingRequest request) async {
        Future<void>.delayed(const Duration(seconds: 1), () {
          setPairingRequestHandler(null);
        });
        if (pin != null && request.variant == BluetoothPairingVariant.pin) {
          return pin;
        }

        if (passkeyConfirm != null &&
            (request.variant == BluetoothPairingVariant.consent ||
                request.variant ==
                    BluetoothPairingVariant.passkeyConfirmation)) {
          return passkeyConfirm;
        }

        // Other pairing variant used, cannot automate
        return null;
      });
    }

    return await methodChannel.invokeMethod(
          'bondDevice',
          <String, dynamic>{'address': address},
        ) ??
        false;
  }

  @override
  Future<String> connect(final String address) async {
    return await methodChannel.invokeMethod(
          'connect',
          <String, dynamic>{'address': address},
        ) ??
        -1;
  }

  // TODO(edufolly): Write

  @override
  Future<void> disconnect(final String id) {
    return methodChannel.invokeMethod(
      'disconnect',
      <String, dynamic>{'id': id},
    );
  }
}
