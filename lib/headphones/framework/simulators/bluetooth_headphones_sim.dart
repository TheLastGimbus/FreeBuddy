import 'package:rxdart/rxdart.dart';

import '../bluetooth_headphones.dart';
import '../headphones_info.dart';

/// A handy mixin that can emulate BluetoothHeadphones properties
/// if a mixed class implements HeadphonesModelInfo
// It is very simple for now - in future, we may simulate the battery dropping etc
mixin BluetoothHeadphonesSim on HeadphonesModelInfo
    implements BluetoothHeadphones {
  // TODO: Make this random so that it won't mix up in far future
  @override
  String get macAddress => "AA:BB:CC:DD:EE:FF";

  @override
  String get bluetoothName => '$vendor $name';

  @override
  ValueStream<String> get bluetoothAlias => Stream.value(name).shareValue();

  @override
  ValueStream<int> get batteryLevel => Stream.value(100).shareValue();
}

mixin BluetoothHeadphonesSimPlaceholder on HeadphonesModelInfo
    implements BluetoothHeadphones {
  @override
  String get macAddress => "";

  @override
  String get bluetoothName => '$vendor $name';

  @override
  ValueStream<String> get bluetoothAlias => BehaviorSubject();

  @override
  ValueStream<int> get batteryLevel => BehaviorSubject();
}
