import 'package:flutter_test/flutter_test.dart';
import 'package:freebuddy/headphones/huawei/otter/otter_constants.dart';

void main() {
  group("Device constants tests", () {
    test("Otter name regex match", () {
      expect(OtterConst.btDevNameRegex.any((regex) => regex.hasMatch("HUAWEI FreeBuds 4i")), true);
      expect(OtterConst.btDevNameRegex.any((regex) => regex.hasMatch("HUAWEI FreeBuds 4i ")), true);
      expect(OtterConst.btDevNameRegex.any((regex) => regex.hasMatch("huawei freebuds 4i")), false);
      expect(OtterConst.btDevNameRegex.any((regex) => regex.hasMatch("HUAWEI FreeBuds Pro")), true);
    });
  });
}
