enum BluetoothDeviceType {
  classic(1),
  le(2),
  dual(3),
  unknown(-2);

  final int value;

  const BluetoothDeviceType(this.value);

  static BluetoothDeviceType parse(final dynamic value) {
    final int intValue =
        int.tryParse(value.toString()) ?? BluetoothDeviceType.unknown.value;

    return BluetoothDeviceType.values.firstWhere(
      (final BluetoothDeviceType e) => e.value == intValue,
      orElse: () => BluetoothDeviceType.unknown,
    );
  }
}
