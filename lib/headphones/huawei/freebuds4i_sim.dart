import '../simulators/anc_sim.dart';
import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import 'freebuds4i.dart';

final class HuaweiFreeBuds4iSim extends HuaweiFreeBuds4i
    with BluetoothHeadphonesSim, LRCBatteryAlwaysFullSim, AncSim {}
