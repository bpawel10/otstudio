import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';

class OtbmSerializer extends DiskSerializer<AreaMap> {
  @override
  void serialize(
      ProgressTracker<DiskSerializerSerializePayload<AreaMap>> tracker) {
    // TODO: implement serialize
  }

  @override
  Future<AreaMap> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) async {
    print('OtbmSerializer.deserialize, path ${tracker.data.path}');
    Uint8List bytes = await File(tracker.data.path).readAsBytes();
    print('bytes length ${bytes.length}');
    ReadBuffer buffer = ReadBuffer(ByteData.view(bytes.buffer));
    AreaMap map = AreaMap.empty();

    String identifier = String.fromCharCodes(buffer.getUint8List(4));
    print('identifier ${identifier}');

    if (buffer.getUint8() == _OtbmSpecialCharacter.start) {
      int node = buffer.getUint8();
      if (node == _OtbmNodeType.root) {
        int version = buffer.getUint32(endian: Endian.little);
        print('version ${version}');
        int width = buffer.getUint16(endian: Endian.little);
        map.width = width;
        print('width ${width}');
        int height = buffer.getUint16(endian: Endian.little);
        map.height = height;
        print('height ${height}');
        int itemsMajorVersion = buffer.getUint32(endian: Endian.little);
        int itemsMinorVersion = buffer.getUint32(endian: Endian.little);

        if (buffer.getUint8() == _OtbmSpecialCharacter.start) {
          int node = buffer.getUint8();
          if (node == _OtbmNodeType.mapData) {
            while (true) {
              int byte = buffer.getUint8();

              if (byte == _OtbmSpecialCharacter.end) {
                break;
              }

              if (byte == _OtbmSpecialCharacter.escape) {
                continue;
              }

              if (byte == _OtbmSpecialCharacter.start) {
                int node2 = buffer.getUint8();
                if (node2 == _OtbmNodeType.tileArea) {
                  int offsetX = buffer.getUint16(endian: Endian.little);
                  int offsetY = buffer.getUint16(endian: Endian.little);
                  int offsetZ = buffer.getUint8();
                  print('offsetX $offsetX offsetY $offsetY offsetZ $offsetZ');
                  if (buffer.getUint8() == _OtbmSpecialCharacter.start) {
                    if (buffer.getUint8() == _OtbmNodeType.tile) {
                      int x = buffer.getUint8();
                      if (x == _OtbmSpecialCharacter.escape) {
                        x = buffer.getUint8();
                      }
                      int y = buffer.getUint8();
                      if (y == _OtbmSpecialCharacter.escape) {
                        y = buffer.getUint8();
                      }
                      print('x $x y $y');

                      Position position =
                          Position(offsetX + x, offsetY + y, offsetZ);

                      while (true) {
                        int byte = buffer.getUint8();

                        print('byte $byte');

                        if (byte == _OtbmSpecialCharacter.end) {
                          break;
                        }

                        if (byte == _OtbmSpecialCharacter.escape) {
                          continue;
                        }

                        if (byte == _OtbmSpecialCharacter.start) {
                          if (buffer.getUint8() == _OtbmNodeType.item) {
                            while (true) {
                              int byte = buffer.getUint8();

                              if (byte == _OtbmSpecialCharacter.end) {
                                break;
                              }

                              if (byte == _OtbmSpecialCharacter.escape) {
                                continue;
                              }

                              int? itemId;

                              switch (byte) {
                                case _OtbmAttribute.item:
                                  itemId =
                                      buffer.getUint16(endian: Endian.little);
                                  break;
                              }

                              if (itemId != null) {
                                map.addItem(position,
                                    Item(id: itemId, name: itemId.toString()));
                              }
                            }
                          }
                        }

                        int? groundId;

                        switch (byte) {
                          case _OtbmAttribute.item:
                            print('attr.item');
                            groundId = buffer.getUint16(endian: Endian.little);
                            print('groundId0 $groundId');
                            break;
                        }

                        print('aaa');

                        if (groundId != null) {
                          print('groundId not null 1');
                          map.addItem(position,
                              Item(id: groundId, name: groundId.toString()));
                          print('groundId not null 2');
                          print('groundId $groundId');
                        }
                      }
                    }
                  }
                }
              }

              switch (byte) {
                case _OtbmAttribute.description:
                  int length = buffer.getUint16(endian: Endian.little);
                  String description =
                      String.fromCharCodes(buffer.getUint8List(length));
                  print('description ${description}');
                  break;
                case _OtbmAttribute.extFile:
                  int length = buffer.getUint16(endian: Endian.little);
                  String extFile =
                      String.fromCharCodes(buffer.getUint8List(length));
                  print('extFile ${extFile}');
                  break;
                case _OtbmAttribute.extSpawnFile:
                  int length = buffer.getUint16(endian: Endian.little);
                  String extSpawnFile =
                      String.fromCharCodes(buffer.getUint8List(length));
                  print('extSpawnFile ${extSpawnFile}');
                  break;
                case _OtbmAttribute.extHouseFile:
                  int length = buffer.getUint16(endian: Endian.little);
                  String extHouseFile =
                      String.fromCharCodes(buffer.getUint8List(length));
                  print('extHouseFile ${extHouseFile}');
                  break;
              }
            }
          }
        }
      }
    }

    print(
        'deserialized otbm map ${map.toString()} width ${map.width} height ${map.height}');
    debugPrint(map.getTiles().toString());

    return map;
  }
}

abstract class _OtbmSpecialCharacter {
  static const start = 0xFE;
  static const end = 0xFF;
  static const escape = 0xFD;
}

abstract class _OtbmNodeType {
  static const root = 0x00;
  static const mapData = 0x02;
  static const tileArea = 0x04;
  static const tile = 0x05;
  static const item = 0x06;
  static const towns = 0x0C;
  static const town = 0x0D;
  static const houseTile = 0x0E;
  static const waypoints = 0x0F;
  static const waypoint = 0x10;
}

abstract class _OtbmAttribute {
  static const description = 0x01;
  static const extFile = 0x02;
  static const tileFlags = 0x03;
  static const actionId = 0x04;
  static const uniqueId = 0x05;
  static const text = 0x06;
  static const destination = 0x08;
  static const item = 0x09;
  static const depotId = 0x0A;
  static const extSpawnFile = 0x0B;
  static const extHouseFile = 0x0D;
  static const houseDoorId = 0x0E;
  static const count = 0x0F;
  static const runeCharges = 0x16;
}
