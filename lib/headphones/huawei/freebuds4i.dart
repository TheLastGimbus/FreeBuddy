import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';

/// Base abstract class of 4i's. It contains static info like vendor names etc,
/// but no logic whatsoever.
///
/// It makes both a solid ground for actual implementation (by defining what
/// features they implement), and some basic info for easy simulation
abstract base class HuaweiFreeBuds4i
    implements BluetoothHeadphones, HeadphonesModelInfo {
  @override
  String get vendor => "Huawei";

  @override
  String get name => "FreeBuds 4i";
}
