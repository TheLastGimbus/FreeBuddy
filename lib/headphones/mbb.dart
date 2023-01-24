import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';

extension _ListUtils on List {
  bool elementsEqual(List other) {
    return const ListEquality().equals(this, other);
  }
}

extension _MapUtils on Map {
  bool elementsEqual(Map other) {
    return const MapEquality().equals(this, other);
  }
}

/// Helper class for Mbb protocol used to communicate with headphones
class Mbb {
  // plus 3 magic bytes + 2 command bytes
  static int getLength(int lengthByte) => lengthByte + 3 + 2;

  /// Get Crc16Xmodem checksum of [data] as Uin8List of two bytes
  static Uint8List _checksum(List<int> data) {
    final crc = Crc16Xmodem().convert(data);
    final str = crc.toRadixString(16);
    final hexes = [str.substring(0, 2), str.substring(2)];
    final bytes = hexes.map((hex) => int.parse(hex, radix: 16));
    return Uint8List.fromList(bytes.toList());
  }

  static Uint8List _getDataFromArgs(Map<int, List<int>> args) {
    final data = <int>[];
    args.forEach((key, value) {
      data.add(key);
      data.add(value.length);
      data.addAll(value);
    });
    return Uint8List.fromList(data);
  }

  /// Get Mbb data to be sent to headphones
  static Uint8List getPayload(
      int serviceId, int commandId, Map<int, List<int>> args) {
    assert(serviceId >= 0 && serviceId <= 255);
    assert(commandId >= 0 && commandId <= 255);
    final data = _getDataFromArgs(args);
    final byteLength = data.length + 2 + 1; // +2->checksums +1->*because*
    assert(byteLength <= 255);
    final bytesList = [
      90, // Magic bytes
      0, //
      byteLength,
      0, // another magic byte (i think)
      serviceId,
      commandId,
      ...Uint8List.fromList(data), // Make sure they are >0 and <256
    ];
    return Uint8List.fromList(bytesList..addAll(_checksum(bytesList)));
  }

  /// Checks if checksums are alright
  static bool verifyChecksum(Uint8List payload) {
    final checksum = _checksum(payload.sublist(0, payload.length - 2));
    return checksum[0] == payload[payload.length - 2] &&
        checksum[1] == payload[payload.length - 1];
  }

  /// Will throw exception if anything wrong. Otherwise does nothing.
  static Exception? verifyIntegrity(Uint8List payload, {bool checksum = true}) {
    // 3 magic bytes, 1 length, 1 service, 1 command, 2 checksum
    if (payload.length < 3 + 1 + 1 + 1 + 2) {
      return Exception("Payload $payload is too short");
    }
    if (!payload.sublist(0, 2).elementsEqual([90, 0]) || payload[3] != 0) {
      return Exception("Payload $payload has invalid magic bytes");
    }
    if (payload.length - 6 + 1 != payload[2]) {
      return Exception("Length data from $payload doesn't match length byte");
    }
    if (checksum && !verifyChecksum(payload)) {
      return Exception("Checksum from $payload doesn't match");
    }
    return null;
  }
}

/// Helper class to contain info about single command
class MbbCommand {
  final int serviceId;
  final int commandId;
  final Map<int, List<int>> args;

  const MbbCommand(this.serviceId, this.commandId, this.args);

  @override
  String toString() => 'MbbCommand(serviceId: $serviceId, '
      'commandId: $commandId, dataArgs: $args)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MbbCommand &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          commandId == other.commandId &&
          args.elementsEqual(other.args);

  @override
  int get hashCode => serviceId.hashCode ^ commandId.hashCode ^ args.hashCode;

  /// Convert to binary data to be sent to headphones
  Uint8List toPayload() => Mbb.getPayload(serviceId, commandId, args);

  static List<MbbCommand> fromPayload(
    Uint8List payload, {
    bool verify = true,
    bool smartDivide = true,
  }) {
    final divided = <Uint8List>[];
    if (smartDivide) {
      while (payload.length >= 8) {
        divided.add(payload.sublist(0, Mbb.getLength(payload[2])));
        payload = payload.sublist(Mbb.getLength(payload[2]));
      }
    } else {
      divided.add(payload);
    }
    if (divided.isEmpty) {
      if (verify) {
        throw Exception("No commands found in payload");
      } else {
        return [];
      }
    }
    final cmds = <MbbCommand>[];
    for (final divPay in divided) {
      if (verify) {
        final e = Mbb.verifyIntegrity(divPay);
        if (e != null) throw e;
      }
      final serviceId = divPay[4];
      final commandId = divPay[5];
      final dataBytes = divPay.sublist(6, divPay.length - 2);

      final args = <int, List<int>>{};
      var offset = 0;
      while (offset < dataBytes.length) {
        final argId = dataBytes[offset];
        final argLength = dataBytes[offset + 1];
        // TODO: Check if argLength is valid and not too big
        final argData = dataBytes.sublist(offset + 2, offset + 2 + argLength);
        offset += 2 + argLength;
        args[argId] = argData;
      }
      cmds.add(MbbCommand(serviceId, commandId, args));
    }
    return cmds;
  }

  static const ancNoiseCancel = MbbCommand(43, 4, {
    1: [1, 255]
  });
  static const ancOff = MbbCommand(43, 4, {
    1: [0, 0]
  });
  static const ancAware = MbbCommand(43, 4, {
    1: [2, 255]
  });
  static const requestBattery = MbbCommand(1, 8, {});
  static const requestAnc = MbbCommand(43, 42, {});
}
