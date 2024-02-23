import 'package:rxdart/rxdart.dart';

/// A base class for *all* different bluetooth headphones. Whether it be
/// a generic old 10$ headphones, or super smart AirPods with 100 different
/// ANC modes - all of them need to implement at least this
///
/// Watch out for documentation of each property 👀
abstract class BluetoothHeadphones {
  /// Very normal mac address, in hex and upper-case
  String get macAddress;

  /// Very normal bluetooth name
  String get bluetoothName;

  /// Alias that user can set in their OS
  ///
  /// If they can't, or didn't do so, then... idk honestly whether to emit a
  /// null or never emit or emit same as [bluetoothName]...
  ///
  /// You know what - do same as OS. If OS sends you same as their name - emit
  /// this. If OS doesn't give you anything - just don't.
  ValueStream<String> get bluetoothAlias;

  /// Generic battery level, probably got from OS - watch out that this may
  /// never emit cause **some** OSes/headphones still don't support it
  ValueStream<int> get batteryLevel;
}
