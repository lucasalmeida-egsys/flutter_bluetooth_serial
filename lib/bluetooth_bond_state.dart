enum BluetoothBondState {
  none(10),
  bonding(11),
  bonded(12),
  unknown(-2);

  final int value;

  const BluetoothBondState(this.value);

  static BluetoothBondState parse(final dynamic value) {
    final int intValue =
        int.tryParse(value.toString()) ?? BluetoothBondState.unknown.value;

    return BluetoothBondState.values.firstWhere(
      (final BluetoothBondState e) => e.value == intValue,
      orElse: () => BluetoothBondState.unknown,
    );
  }

  bool get isBonded => this == bonded;
}
