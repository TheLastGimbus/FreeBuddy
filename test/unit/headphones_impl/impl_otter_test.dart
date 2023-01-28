import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:freebuddy/headphones/headphones_data_objects.dart';
import 'package:freebuddy/headphones/huawei/mbb.dart';
import 'package:freebuddy/headphones/huawei/otter/headphones_impl_otter.dart';
import 'package:stream_channel/stream_channel.dart';

void main() {
  group("Otter implementation tests", () {
    // test with keyword "info" test if impl reacts to info *from* buds
    // ones with "set" test if impl sends correct bytes *to* buds

    late StreamController<Uint8List> inputCtrl;
    late StreamController<Uint8List> outputCtrl;
    late StreamChannel<Uint8List> channel;
    late HeadphonesImplOtter otter;
    setUp(() {
      inputCtrl = StreamController<Uint8List>.broadcast();
      outputCtrl = StreamController<Uint8List>();
      channel = StreamChannel<Uint8List>(inputCtrl.stream, outputCtrl.sink);
      otter = HeadphonesImplOtter(channel);
    });
    tearDown(() {
      inputCtrl.close();
      outputCtrl.close();
    });
    test("Request data on start", () async {
      expect(
        outputCtrl.stream.bytesToList(),
        emitsInAnyOrder([
          [90, 0, 3, 0, 1, 8, 223, 115],
          [90, 0, 3, 0, 43, 42, 50, 126],
        ]),
      );
    });
    test("ANC mode set", () async {
      await otter.setAncMode(HeadphonesAncMode.noiseCancel);
      expect(
        outputCtrl.stream.bytesToList(),
        emitsThrough([90, 0, 7, 0, 43, 4, 1, 2, 1, 255, 255, 236]),
      );
    });
    test("ANC mode info", () async {
      const cmds = [
        MbbCommand(43, 42, {
          1: [4, 1]
        }),
        MbbCommand(43, 42, {
          1: [0, 0]
        }),
        MbbCommand(43, 42, {
          1: [0, 2]
        }),
        MbbCommand(43, 42, {
          1: [0, 2]
        }),
      ];
      for (var c in cmds) {
        inputCtrl.add(c.toPayload());
      }
      expect(
        otter.ancMode,
        emitsInOrder([
          HeadphonesAncMode.noiseCancel,
          HeadphonesAncMode.off,
          HeadphonesAncMode.awareness,
          HeadphonesAncMode.awareness,
        ]),
      );
    });
    test("Battery info", () async {
      inputCtrl.add(const MbbCommand(1, 39, {
        1: [35],
        2: [35, 70, 99],
        3: [1, 0, 1]
      }).toPayload());
      expect(
        otter.batteryData,
        emits(HeadphonesBatteryData(35, 70, 99, true, false, true)),
      );
    });
    test("Properly closes", () async {
      expectLater(
        otter.ancMode,
        emitsInOrder([HeadphonesAncMode.noiseCancel, emitsDone]),
      );
      expectLater(otter.batteryData, emitsDone);
      inputCtrl.add(const MbbCommand(43, 42, {
        1: [4, 1]
      }).toPayload());
      await inputCtrl.close();
    });
  });
}

extension on Stream<Uint8List> {
  Stream<List<int>> bytesToList() => map((event) => event.toList());
}
