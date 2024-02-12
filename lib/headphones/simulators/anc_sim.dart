import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';

/// Simulates anc actually being switched on the headphones
mixin AncSim implements Anc {
  final _ancModeCtrl = BehaviorSubject<AncMode>();

  @override
  ValueStream<AncMode> get ancMode => _ancModeCtrl;

  @override
  Future<void> setAncMode(AncMode mode) async => _ancModeCtrl.add(mode);
}
