enum BluetoothPairingVariant {
  pin(0),
  passkey(1),
  passkeyConfirmation(2),
  consent(3),
  displayPasskey(4),
  displayPin(5),
  oob(6),
  pin16Digits(7),
  error(-1),
  unknown(-2);

  final int value;

  const BluetoothPairingVariant(this.value);

  static BluetoothPairingVariant parse(final dynamic value) {
    final int intValue =
        int.tryParse(value.toString()) ?? BluetoothPairingVariant.unknown.value;

    return BluetoothPairingVariant.values.firstWhere(
      (final BluetoothPairingVariant e) => e.value == intValue,
      orElse: () => BluetoothPairingVariant.unknown,
    );
  }
}
