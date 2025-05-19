import 'package:rxdart/rxdart.dart';

abstract class Anc {
  ValueStream<AncMode> get ancMode;
  ValueStream<AncLevel> get ancLevel;

  Future<void> setAncMode(AncMode mode);
  Future<void> setAncLevel(AncLevel level);
  bool get supportsAncLevel;
}

enum AncMode {
  noiseCancelling,
  off,
  transparency,
}

enum AncLevel {
  normal,
  comfort,
  ultra,
  dynamic,
}
