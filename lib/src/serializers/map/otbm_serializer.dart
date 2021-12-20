import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';

class OtbmSerializer extends DiskSerializer<AreaMap> {
  static const FLOORS = 16;
  static const TILE_AREA_TILES = 256 * 256;

  List<Item> items;

  OtbmSerializer(this.items);

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
    // ReadBuffer otbm = ReadBuffer(ByteData.view(bytes.buffer));

    _OtbmReader otbm = _OtbmReader(bytes);

    // String identifier = String.fromCharCodes(otbm.getUint8List(4));
    // print('identifier $identifier');

    AreaMap map = AreaMap.empty();

    otbm.getUint32();

    if (otbm.getNode() == _OtbmNodeType.root) {
      int version = otbm.getUint32();
      print('version $version');
      int width = otbm.getUint16();
      map.width = width;
      print('width $width');
      int height = otbm.getUint16();
      map.height = height;
      print('height $height');
      int itemsMajorVersion = otbm.getUint32();
      int itemsMinorVersion = otbm.getUint32();

      int TOTAL_TILES_PER_FLOOR = width * height;
      int TOTAL_TILES = TOTAL_TILES_PER_FLOOR * FLOORS;

      int TOTAL_TILE_AREAS = (width * height * FLOORS / TILE_AREA_TILES).ceil();
      int tileAreas = 0;

      if (otbm.getNode() == _OtbmNodeType.mapData) {
        int byte = otbm.getUint8();

        while (byte != _OtbmSpecialCharacter.end) {
          // print('byte0 $byte');
          switch (byte) {
            case _OtbmAttribute.description:
              String description = otbm.getString();
              print('description $description');
              break;
            case _OtbmAttribute.extFile:
              String extFile = otbm.getString();
              print('extFile $extFile');
              break;
            case _OtbmAttribute.extSpawnFile:
              String extSpawnFile = otbm.getString();
              print('extSpawnFile $extSpawnFile');
              break;
            case _OtbmAttribute.extHouseFile:
              String extHouseFile = otbm.getString();
              print('extHouseFile $extHouseFile');
              break;
            case _OtbmSpecialCharacter.start:
              int byte1 = byte;

              // print('byte1 $byte1');

              while (byte1 != _OtbmSpecialCharacter.end) {
                int byte1Type = otbm.getUint8();
                // print('byte1Type $byte1Type');
                if (byte1Type == _OtbmNodeType.tileArea) {
                  // print('tile area node');
                  int offsetX = otbm.getUint16();
                  int offsetY = otbm.getUint16();
                  int offsetZ = otbm.getUint8();
                  // print('offsetX $offsetX offsetY $offsetY offsetZ $offsetZ');

                  int byte2 = otbm.getUint8();

                  while (byte2 != _OtbmSpecialCharacter.end) {
                    // print('byte2 $byte2');

                    int tileType = otbm.getUint8();
                    if ([_OtbmNodeType.tile, _OtbmNodeType.houseTile]
                        .contains(tileType)) {
                      // print('tile/housetile node');
                      int x = otbm.getUint8();
                      int y = otbm.getUint8();
                      // print('x $x y $y');

                      Position position =
                          Position(offsetX + x, offsetY + y, offsetZ);

                      int? groundId;

                      int byte3 = otbm.getUint8();

                      while (byte3 != _OtbmSpecialCharacter.end) {
                        // print('byte3 $byte3');

                        // print('tileAttr $tileAttr');

                        switch (byte3) {
                          case _OtbmAttribute.tileFlags:
                            int tileFlags = otbm.getUint32();
                            break;
                          case _OtbmAttribute.item:
                            groundId = otbm.getUint16();
                            break;
                        }

                        if (groundId != null) {
                          // print('groundId $groundId');
                          map.addItem(
                              position,
                              Item(
                                id: groundId,
                                name: groundId.toString(),
                                ground: true,
                              ));
                        }

                        if (tileType == _OtbmNodeType.houseTile) {
                          int houseId = otbm.getUint32();
                        }

                        Item? item =
                            otbm.getItem(byte3, position, version, items);

                        if (item != null) {
                          map.addItem(position, item);
                        }

                        byte3 = otbm.getUint8();

                        // print('byte3.2 $byte3');
                      }

                      byte2 = otbm.getUint8();

                      // print('byte2.2 $byte2');
                    }

                    // byte2 = otbm.getUint8();

                    // print('byte2.2 $byte2');
                  }

                  // byte1 = otbm.getUint8();

                  // print('byte1.2 $byte');

                  // tileAreas++;
                  // print(
                  //     'tileAreas $tileAreas TOTAL_TILE_AREAS $TOTAL_TILE_AREAS');
                  // tracker.progress = tileAreas / TOTAL_TILE_AREAS;

                  tracker.progress = otbm
                      .getProgress(); // offsetX * offsetY / TOTAL_TILES_PER_FLOOR;
                }

                byte1 = otbm.getUint8();

                // print('byte1.2 $byte1');
              }
          }

          byte = otbm.getUint8();

          // print('byte0.2 $byte');
        }

        // if (node == _OtbmSpecialCharacter.end) {
        // node = otbm.getNode();
        // }
      }
    }

    map.getVisibleTilesForPosition(Position(32369, 32241, 7)); // size));

    print(
        'deserialized otbm map ${map.toString()} width ${map.width} height ${map.height} tiles ${map.tiles.length}');
    // debugPrint(map.getTiles().toString());

    return map;
  }

  // int _readNode(ReadBuffer buffer) {
  //   int byte = buffer.getUint8();

  //   if (byte == _OtbmSpecialCharacter.start) {
  //     int type = buffer.getUint8();
  //     return type;
  //   }
  // }

  // String readString(ReadBuffer buffer) {
  //   int length = buffer.getUint16(endian: Endian.little);
  //   String string = String.fromCharCodes(buffer.getUint8List(length));
  //   return string;
  // }
}

class _OtbmReader {
  late ReadBuffer reader;
  int pos = 0;

  _OtbmReader(Uint8List bytes) {
    reader = ReadBuffer(ByteData.view(bytes.buffer));
  }

  double getProgress() {
    return pos / reader.data.lengthInBytes;
  }

  int? getNode({bool skip = false}) {
    if (skip) {
      int type = getUint8();
      // print('type (skip) $type');
      return type;
    }

    int char = getUint8();
    // print('char $char');
    switch (char) {
      case _OtbmSpecialCharacter.start:
        int type = getUint8();
        // print('type $type');
        return type;
      case _OtbmSpecialCharacter.end:
        return char;
      default:
        return null;
    }
  }

  void getAttribute(int attribute) {
    switch (attribute) {
      case _OtbmAttribute.description:
        break;
      case _OtbmAttribute.extFile:
        break;
      case _OtbmAttribute.tileFlags:
        break;
      case _OtbmAttribute.actionId:
        int actionId = getUint16();
        break;
      case _OtbmAttribute.uniqueId:
        int uniqueId = getUint16();
        break;
      case _OtbmAttribute.text:
        String text = getString();
        break;
      case _OtbmAttribute.desc:
        String desc = getString();
        break;
      case _OtbmAttribute.destination:
        int x = getUint16();
        int y = getUint16();
        int z = getUint8();
        break;
      case _OtbmAttribute.item:
        break;
      case _OtbmAttribute.depotId:
        int depotId = getUint16();
        break;
      case _OtbmAttribute.extSpawnFile:
        break;
      case _OtbmAttribute.runeCharges:
        int subtype = getUint8();
        break;
      case _OtbmAttribute.extHouseFile:
        break;
      case _OtbmAttribute.runeCharges:
        break;
      case _OtbmAttribute.extHouseFile:
        break;
      case _OtbmAttribute.houseDoorId:
        int houseDoorId = getUint8();
        break;
      case _OtbmAttribute.count:
        int subtype = getUint8();
        break;
      case _OtbmAttribute.duration:
        break;
      case _OtbmAttribute.decayingState:
        break;
      case _OtbmAttribute.writtenDate:
        break;
      case _OtbmAttribute.writtenBy:
        break;
      case _OtbmAttribute.sleeperGuid:
        break;
      case _OtbmAttribute.sleepStart:
        break;
      case _OtbmAttribute.charges:
        int charges = getUint16();
        break;
      case _OtbmAttribute.map:
        break;
    }
  }

  int getUint8() {
    int uint8 = reader.getUint8();
    pos++;
    // print('uint8 $uint8');
    if (uint8 == _OtbmSpecialCharacter.escape) {
      uint8 = reader.getUint8();
      pos++;
    }
    return uint8;
  }

  int getUint16() {
    int first = getUint8();
    int second = getUint8();
    return (second << 8) + first;
  }

  int getUint32() {
    int first = getUint8();
    int second = getUint8();
    int third = getUint8();
    int fourth = getUint8();
    return (fourth << 24) + (third << 16) + (second << 8) + first;
  }

  String getString() {
    int length = getUint16();
    List<int> chars = List.empty(growable: true);
    for (int i = 0; i < length; i++) {
      chars.add(getUint8());
    }
    String string = String.fromCharCodes(chars);
    return string;
  }

  Item? getItem(int byte, Position position, int version, List<Item> items) {
    if (byte == _OtbmSpecialCharacter.start) {
      if (getUint8() == _OtbmNodeType.item) {
        // print('item node');
        int itemId = getUint16();
        // print('itemId $itemId');
        int? subtype;

        List<Item> children = List.empty(growable: true);

        int byte2 = getUint8();

        while (byte2 != _OtbmSpecialCharacter.end) {
          switch (byte2) {
            case _OtbmSpecialCharacter.start:
              Item? child = getItem(byte2, position, version, items);
              if (child != null) {
                children.add(child);
              }
              break;
            case _OtbmAttribute.item:
              itemId = getUint16();
              if (version == 1 &&
                  (items[itemId].stackable ||
                      items[itemId].splash ||
                      items[itemId].fluidContainer)) {
                subtype = getUint8();
              }
              break;
            default:
              getAttribute(byte2);
          }

          byte2 = getUint8();
        }

        if (itemId != null) {
          // print(
          //     'item $itemId subtype $subtype position ${position.x} ${position.y} ${position.z}');
          return Item(id: itemId, name: itemId.toString(), children: children);
        }
      }
    }

    return null;
  }
}

// class _OtbmNode {
//   late int _type;
//   ReadBuffer? _buffer;
//   final List<_OtbmNode> _children = List.empty(growable: true);

//   _OtbmNode(Uint8List node) {
//     // print('node.length ${node.length}');
//     // print('a2');
//     // print('bytes $bytes');
//     // List<int> buffer = List.empty(growable: true);
//     // int skip = 0;
//     // bool type = false;
//     // bool escape = false;

//     _type = node[1];
//     node = node.sublist(2, node.length - 1);
//     while (node.isNotEmpty) {
//       // print('1 node.length ${node.lengthInBytes}');
//       // print('node first 4 ${node.sublist(0, 4)}');
//       int nextNodeStart = getNextPositionOf(node, _OtbmSpecialCharacter.start);
//       // print('nextNodeStart $nextNodeStart');
//       if (nextNodeStart >= 0) {
//         // print('2');
//         _setBuffer(escape(node.sublist(0, nextNodeStart)));
//         int nextNodeEnd = getNodeEnd(node);
//         // print('nextNodeEnd $nextNodeEnd');
//         _children.add(_OtbmNode(node.sublist(
//           nextNodeStart,
//           nextNodeEnd + 1,
//         )));
//         node = node.sublist(nextNodeEnd + 1);
//       } else {
//         // print('3');
//         if (_buffer == null) {
//           _setBuffer(escape(node));
//           node = Uint8List(0);
//         }
//         // print('break');
//         // break;
//       }
//       // print('not broken');
//     }

//     // int endPos = getNextPositionOf(bytes, _OtbmSpecialCharacter.end);

//     // if (endPos == 0) {
//     //   return;
//     // }

//     // int startPos =
//     //     getNextPositionOf(bytes, _OtbmSpecialCharacter.start, start: 1);

//     // print('startPos $startPos');
//     // print('endPos $endPos');

//     // print('first 50 bytes ${bytes.sublist(0, 50)}');

//     // if (startPos + endPos >= 0) {
//     //   if (startPos >= 0 && startPos < endPos) {
//     //     print('1');

//     //     _type = bytes[1];
//     //     _setBuffer(escape(bytes.sublist(2, startPos)));
//     //     _children.add(_OtbmNode(bytes.sublist(startPos)));
//     //   } else {
//     //     print('2');
//     //     _type = bytes[1];
//     //     _setBuffer(escape(bytes.sublist(2, endPos)));
//     //     _children.add(_OtbmNode(bytes.sublist(endPos + 1)));
//     //   }
//     // }

//     // print('3');

//     // _type = bytes[1];
//     // _setBuffer(escape(bytes));

//     // print('bytes (first 50) ${bytes.toList().sublist(0, 50)}');

//     // for (MapEntry entry in bytes.asMap().entries) {
//     //   if (skip > 0) {
//     //     skip--;
//     //     continue;
//     //   }

//     //   int pos = entry.key;
//     //   int byte = entry.value;
//     //   // print('pos $pos, byte $byte');

//     //   if (type) {
//     //     print('type=$byte');
//     //     _type = byte;
//     //     type = false;
//     //     continue;
//     //   }
//     //   if (escape) {
//     //     print('escape=true');
//     //     buffer.add(byte);
//     //     escape = false;
//     //     continue;
//     //   }

//     //   switch (byte) {
//     //     case _OtbmSpecialCharacter.start:
//     //       print('byte=start');
//     //       if (buffer.isEmpty) {
//     //         // print('buffer empty');
//     //         type = true;
//     //       } else {
//     //         // print('else');
//     //         Uint8List bufferBytes = Uint8List.fromList(bytes.sublist(pos));
//     //         _OtbmNode child = _OtbmNode(bufferBytes);
//     //         _children.add(child);
//     //         // print('child.escaped ${child.escaped}');
//     //         skip = c child.buffer.data.lengthInBytes + 2;
//     //         buffer.clear();
//     //         buffer.add(byte);
//     //         print('skip $skip');
//     //       }
//     //       break;
//     //     case _OtbmSpecialCharacter.escape:
//     //       escape = true;
//     //       break;
//     //     case _OtbmSpecialCharacter.end:
//     //       _setBuffer(buffer);
//     //       print('--- returned, type $_type');
//     //       return;
//     //     default:
//     //       buffer.add(byte);
//     //   }
//     // }

//     // if (_buffer == null) {
//     //   _setBuffer(buffer);
//     // }

//     // print('--- ended, type $_type');
//   }

//   int getNextPositionOf(Uint8List bytes, int byte, {int start = 0}) {
//     int pos;
//     while (true) {
//       // print('4');
//       pos = bytes.indexWhere((b) => b == byte, start);
//       // print('pos $pos');

//       if (pos < 1 || bytes[pos - 1] != _OtbmSpecialCharacter.escape) {
//         break;
//       }

//       start = pos + 1;
//     }
//     return pos;
//   }

//   int getNodeEnd(Uint8List bytes) {
//     int start = 0;
//     int pos = 0;
//     int starts = 0;
//     int ends = 0;

//     while (ends == 0 || ends < starts) {
//       // print('starts $starts, ends $ends, pos $pos, start $start');
//       pos = bytes.indexWhere(
//           (byte) => [_OtbmSpecialCharacter.start, _OtbmSpecialCharacter.end]
//               .contains(byte),
//           start);
//       start = pos + 1;

//       if (pos >= 1 && bytes[pos - 1] == _OtbmSpecialCharacter.escape) {
//         continue;
//       }

//       int byte = bytes[pos];
//       switch (byte) {
//         case _OtbmSpecialCharacter.start:
//           starts++;
//           break;
//         case _OtbmSpecialCharacter.end:
//           ends++;
//           break;
//       }
//     }

//     return pos;
//   }

//   List<int> escape(List<int> bytes) {
//     List<int> escaped = List.from(bytes, growable: true);
//     // TODO: fix this, handle case where escape char escapes escape char
//     escaped.removeWhere((byte) => byte == _OtbmSpecialCharacter.escape);
//     return escaped;
//   }

//   void addChild(Uint8List bytes) {
//     _children.add(_OtbmNode(bytes));
//   }

//   int get type {
//     return _type;
//   }

//   ReadBuffer get buffer {
//     return _buffer!;
//   }

//   // int get escaped {
//   //   return _escaped;
//   // }

//   List<_OtbmNode> get children {
//     return _children;
//   }

//   int getUint16() {
//     return _buffer!.getUint16(endian: Endian.little);
//   }

//   int getUint32() {
//     return _buffer!.getUint32(endian: Endian.little);
//   }

//   int getUint8() {
//     return _buffer!.getUint8();
//   }

//   Uint8List getUint8List(int length) {
//     return _buffer!.getUint8List(length);
//   }

//   bool get hasRemaining => _buffer?.hasRemaining ?? false;

//   void _setBuffer(List<int> buffer) {
//     Uint8List bufferBytes = Uint8List.fromList(buffer);
//     _buffer = ReadBuffer(ByteData.view(bufferBytes.buffer));
//   }
// }

abstract class _OtbmSpecialCharacter {
  static const start = 0xFE;
  static const end = 0xFF;
  static const escape = 0xFD;
}

abstract class _OtbmNodeType {
  static const root = 0x00;
  static const rootV1 = 0x01;
  static const mapData = 0x02;
  static const itemDef = 0x03;
  static const tileArea = 0x04;
  static const tile = 0x05;
  static const item = 0x06;
  static const tileSquare = 0x07;
  static const tileRef = 0x08;
  static const spawns = 0x09;
  static const spawnArea = 0x0A;
  static const monster = 0x0B;
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
  static const desc = 0x07; // what is it?
  static const destination = 0x08;
  static const item = 0x09;
  static const depotId = 0x0A;
  static const extSpawnFile = 0x0B;
  static const runeCharges = 0x0C;
  static const extHouseFile = 0x0D;
  static const houseDoorId = 0x0E;
  static const count = 0x0F;
  static const duration = 0x10;
  static const decayingState = 0x11;
  static const writtenDate = 0x12;
  static const writtenBy = 0x13;
  static const sleeperGuid = 0x14;
  static const sleepStart = 0x15;
  static const charges = 0x16;
  static const map = 0x80;
}
