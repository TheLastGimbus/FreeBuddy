import '../headphones_base.dart';

abstract class HeadphonesConnectionState {}

class HeadphonesNoPermission extends HeadphonesConnectionState {}

class HeadphonesBluetoothDisabled extends HeadphonesConnectionState {}

class HeadphonesNotPaired extends HeadphonesConnectionState {}

class HeadphonesDisconnected extends HeadphonesConnectionState {}

class HeadphonesConnecting extends HeadphonesConnectionState {}

class HeadphonesConnectedOpen extends HeadphonesConnectionState {
  final HeadphonesBase headphones;

  HeadphonesConnectedOpen(this.headphones);
}

class HeadphonesConnectedClosed extends HeadphonesConnectionState {}
