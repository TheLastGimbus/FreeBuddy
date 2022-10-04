import 'package:flutter_test/flutter_test.dart';
import 'package:freebuddy/headphones/otter_constants.dart';

void main() {
  group("Device constants tests", () {
    test("Otter name regex match", () {
      expect(Otter.btDevNameRegex.hasMatch("HUAWEI FreeBuds 4i"), true);
      expect(Otter.btDevNameRegex.hasMatch("HUAWEI FreeBuds 4i "), true);
      expect(Otter.btDevNameRegex.hasMatch("huawei freebuds 4i"), false);
      expect(Otter.btDevNameRegex.hasMatch("HUAWEI FreeBuds Pro"), false);
    });
  });
}
