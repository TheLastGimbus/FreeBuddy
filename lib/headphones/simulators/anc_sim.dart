import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';

/// Simulates anc actually being switched on the headphones
mixin AncSim implements Anc {
  final _ancModeCtrl = BehaviorSubject<AncMode>.seeded(AncMode.off);

  @override
  ValueStream<AncMode> get ancMode => _ancModeCtrl;

  @override
  Future<void> setAncMode(AncMode mode) async => _ancModeCtrl.add(mode);
}

mixin AncSimPlaceholder implements Anc {
  @override
  ValueStream<AncMode> get ancMode => BehaviorSubject();

  @override
  Future<void> setAncMode(AncMode mode) async {}
}
