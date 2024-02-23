import '../framework/bluetooth_headphones.dart';

abstract class HeadphonesConnectionState {
  const HeadphonesConnectionState();
}

class HeadphonesNoPermission extends HeadphonesConnectionState {
  const HeadphonesNoPermission();
}

class HeadphonesBluetoothDisabled extends HeadphonesConnectionState {
  const HeadphonesBluetoothDisabled();
}

class HeadphonesNotPaired extends HeadphonesConnectionState {
  const HeadphonesNotPaired();
}

class HeadphonesDisconnected extends HeadphonesConnectionState {
  final BluetoothHeadphones placeholder;

  const HeadphonesDisconnected(this.placeholder);
}

class HeadphonesConnecting extends HeadphonesConnectionState {
  final BluetoothHeadphones placeholder;

  const HeadphonesConnecting(this.placeholder);
}

class HeadphonesConnectedOpen extends HeadphonesConnectionState {
  final BluetoothHeadphones headphones;

  const HeadphonesConnectedOpen(this.headphones);
}

class HeadphonesConnectedClosed extends HeadphonesConnectionState {
  final BluetoothHeadphones placeholder;

  const HeadphonesConnectedClosed(this.placeholder);
}
