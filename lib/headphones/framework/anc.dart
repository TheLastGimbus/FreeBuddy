import 'package:rxdart/rxdart.dart';

abstract class Anc {
  ValueStream<AncMode> get ancMode;

  Future<void> setAncMode(AncMode mode);
}

enum AncMode {
  noiseCancelling,
  off,
  transparency,
}
