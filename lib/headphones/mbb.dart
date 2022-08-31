import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';

extension _ListUtils on List {
  bool elementsEqual(List other) {
    return const ListEquality().equals(this, other);
  }
}

/// Helper class for Mbb protocol used to communicate with headphones
class Mbb {
  /// Get Crc16Xmodem checksum of [data] as Uin8List of two bytes
  static Uint8List _checksum(List<int> data) {
    final crc = Crc16Xmodem().convert(data);
    final str = crc.toRadixString(16);
    final hexes = [str.substring(0, 2), str.substring(2)];
    final bytes = hexes.map((hex) => int.parse(hex, radix: 16));
    return Uint8List.fromList(bytes.toList());
  }

  /// Get Mbb data to be sent to headphones
  static Uint8List getPayload(int serviceId, int commandId, List<int> data) {
    assert(serviceId >= 0 && serviceId <= 255);
    assert(commandId >= 0 && commandId <= 255);
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
      // TODO: This is often :/ add "smart divide"
      //  as in `notes/live_print_data.py`
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
  final List<int> dataBytes;

  const MbbCommand(this.serviceId, this.commandId, this.dataBytes);

  @override
  String toString() => 'MbbCommand(serviceId: $serviceId, '
      'commandId: $commandId, dataBytes: $dataBytes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MbbCommand &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          commandId == other.commandId &&
          dataBytes.elementsEqual(other.dataBytes);

  @override
  int get hashCode =>
      serviceId.hashCode ^ commandId.hashCode ^ dataBytes.hashCode;

  /// Convert to binary data to be sent to headphones
  Uint8List toPayload() => Mbb.getPayload(serviceId, commandId, dataBytes);

  static MbbCommand fromPayload(Uint8List payload, {bool verify = true}) {
    if (verify) {
      final e = Mbb.verifyIntegrity(payload);
      if (e != null) throw e;
    }
    final serviceId = payload[4];
    final commandId = payload[5];
    final dataBytes = payload.sublist(6, payload.length - 2);
    return MbbCommand(serviceId, commandId, dataBytes);
  }

  static const ancNoiseCancel = MbbCommand(43, 4, [1, 2, 1, 255]);
  static const ancOff = MbbCommand(43, 4, [1, 2, 0, 0]);
  static const ancAware = MbbCommand(43, 4, [1, 2, 2, 255]);
}
