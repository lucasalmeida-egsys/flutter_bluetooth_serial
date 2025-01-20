enum BluetoothState {
  off(10),
  turningOn(11),
  on(12),
  turningOff(13),
  error(-1),
  unknown(-2);

  final int value;

  const BluetoothState(this.value);

  static BluetoothState parse(final dynamic value) {
    final int intValue =
        int.tryParse(value.toString()) ?? BluetoothState.unknown.value;

    return BluetoothState.values.firstWhere(
      (final BluetoothState e) => e.value == intValue,
      orElse: () => BluetoothState.unknown,
    );
  }
}
