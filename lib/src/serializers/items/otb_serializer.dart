import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/models/light.dart';

class OtbSerializer extends DiskSerializer<OtbDocument> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<OtbDocument>> tracker) {
    // TODO: implement serialize
    throw UnimplementedError();
  }

  @override
  Future<OtbDocument> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) async {
    Uint8List bytes = await File(tracker.data.path).readAsBytes();
    _OtbNode otb = _OtbNode(bytes.sublist(4));
    otb.getUint8();
    otb.getUint32();

    late int majorVersion;
    late int minorVersion;
    late int buildVersion;

    int attr0 = otb.getUint8();
    if (attr0 == 0x01) {
      // rootattribute.version
      int dataLength = otb.getUint16();
      majorVersion = otb.getUint32();
      minorVersion = otb.getUint32();
      buildVersion = otb.getUint32();
      otb.getUint8List(dataLength - 3 * 4);
    }

    List<_OtbNode> itemNodes = otb.children;
    List<OtbItem> items = [];

    itemNodes.asMap().forEach((int index, _OtbNode itemNode) {
      int group = itemNode.getUint8();
      int flags = itemNode.getUint32();
      // bool stackable =
      //     (flags & _OtbItemFlag.stackable) == _OtbItemFlag.stackable;
      // bool splash = itemGroup == _OtbItemType.splash;
      // bool fluidContainer = itemGroup == _OtbItemType.fluid;

      late int serverId;
      late int clientId;
      String? name;
      int? groundSpeed;
      Uint8List? spriteHash;
      int? minimapColor;
      int? maxReadWriteChars;
      int? maxReadChars;
      Light? light;
      int? stackOrder;
      int? tradeAs;

      while (itemNode.hasRemaining) {
        int attr = itemNode.getUint8();
        int dataLength = itemNode.getUint16();

        switch (attr) {
          case _OtbItemAttribute.serverId:
            serverId = itemNode.getUint16();
            break;
          case _OtbItemAttribute.clientId:
            clientId = itemNode.getUint16();
            break;
          case _OtbItemAttribute.name:
            int length = itemNode.getUint16();
            name = String.fromCharCodes(itemNode.getUint8List(length));
            break;
          case _OtbItemAttribute.groundSpeed:
            groundSpeed = itemNode.getUint16();
            break;
          case _OtbItemAttribute.spriteHash:
            spriteHash = itemNode.getUint8List(dataLength);
            break;
          case _OtbItemAttribute.minimapColor:
            minimapColor = itemNode.getUint16();
            break;
          case _OtbItemAttribute.maxReadWriteChars:
            maxReadWriteChars = itemNode.getUint16();
            break;
          case _OtbItemAttribute.maxReadChars:
            maxReadChars = itemNode.getUint16();
            break;
          case _OtbItemAttribute.light:
            int level = itemNode.getUint16();
            int color = itemNode.getUint16();
            light = Light(level: level, color: color);
            break;
          case _OtbItemAttribute.stackOrder:
            stackOrder = itemNode.getUint8();
            break;
          case _OtbItemAttribute.tradeAs:
            tradeAs = itemNode.getUint16();
            break;
          default:
            itemNode.getUint8List(dataLength);
        }
      }

      OtbItem item = OtbItem(
        group: group,
        flags: flags,
        serverId: serverId,
        clientId: clientId,
        name: name,
        groundSpeed: groundSpeed,
        spriteHash: spriteHash,
        minimapColor: minimapColor,
        maxReadWriteChars: maxReadWriteChars,
        maxReadChars: maxReadChars,
        light: light,
        stackOrder: stackOrder,
        tradeAs: tradeAs,
        // stackable: stackable,
        // splash: splash,
        // fluidContainer: fluidContainer);
      );
      items.add(item);
      tracker.progress = (index + 1) / itemNodes.length;
    });

    return OtbDocument(
        majorVersion: majorVersion,
        minorVersion: minorVersion,
        buildVersion: buildVersion,
        items: items);
  }
}

class OtbDocument {
  final int majorVersion;
  final int minorVersion;
  final int buildVersion;
  final List<OtbItem> items;

  OtbDocument(
      {required this.majorVersion,
      required this.minorVersion,
      required this.buildVersion,
      required this.items});
}

class OtbItem {
  final int group;
  final int flags;
  final int serverId;
  final int clientId;
  final String? name;
  final int? groundSpeed;
  final Uint8List? spriteHash;
  final int? minimapColor;
  final int? maxReadWriteChars;
  final int? maxReadChars;
  final Light? light;
  final int? stackOrder;
  final int? tradeAs;
  // final bool stackable;
  // final bool splash;
  // final bool fluidContainer;

  OtbItem({
    required this.group,
    required this.flags,
    required this.serverId,
    required this.clientId,
    required this.name,
    this.groundSpeed,
    this.spriteHash,
    this.minimapColor,
    this.maxReadWriteChars,
    this.maxReadChars,
    this.light,
    this.stackOrder,
    this.tradeAs,
  });
  // required this.stackable,
  // required this.splash,
  // required this.fluidContainer});
}

abstract class _OtbSpecialCharacter {
  static const start = 0xFE;
  static const end = 0xFF;
  static const escape = 0xFD;
}

class _OtbNode {
  ReadBuffer? _node;
  final List<_OtbNode> _children = List.empty(growable: true);

  _OtbNode(Uint8List bytes) {
    List<int> node = List.empty(growable: true);
    List<int> escapedNode = List.empty(growable: true);
    bool? escape;

    bytes.asMap().forEach((pos, byte) {
      if (escape == true) {
        node.add(byte);
        escapedNode.add(byte);
        escape = false;
        return;
      }

      switch (byte) {
        case _OtbSpecialCharacter.start:
          if (node.isEmpty == false) {
            if (_node == null) {
              _setNode(escapedNode);
            } else {
              Uint8List nodeBytes = Uint8List.fromList(node);
              _OtbNode child = _OtbNode(nodeBytes);
              _children.add(child);
            }
          }
          node.clear();
          escapedNode.clear();
          break;
        case _OtbSpecialCharacter.escape:
          node.add(byte);
          escape = true;
          break;
        case _OtbSpecialCharacter.end:
          break;
        default:
          node.add(byte);
          escapedNode.add(byte);
      }
    });

    if (_node == null) {
      _setNode(escapedNode);
    }
  }

  void addChild(Uint8List bytes) {
    _children.add(_OtbNode(bytes));
  }

  List<_OtbNode> get children {
    return _children;
  }

  int getUint16() {
    return _node!.getUint16(endian: Endian.little);
  }

  int getUint32() {
    return _node!.getUint32(endian: Endian.little);
  }

  int getUint8() {
    return _node!.getUint8();
  }

  Uint8List getUint8List(int length) {
    return _node!.getUint8List(length);
  }

  bool get hasRemaining => _node?.hasRemaining ?? false;

  void _setNode(List<int> node) {
    Uint8List nodeBytes = Uint8List.fromList(node);
    _node = ReadBuffer(ByteData.view(nodeBytes.buffer));
  }
}

abstract class _OtbItemType {
  static const none = 0;
  static const ground = 1;
  static const container = 2;
  static const fluid = 3;
  static const splash = 4;
  static const deprecated = 5;
}

abstract class _OtbItemFlag {
  static const none = 0;
  static const unpassable = 1 << 0;
  static const blockMissiles = 1 << 1;
  static const blockPathfinder = 1 << 2;
  static const hasElevation = 1 << 3;
  static const multiUse = 1 << 4;
  static const pickupable = 1 << 5;
  static const movable = 1 << 6;
  static const stackable = 1 << 7;
  static const floorChangeDown = 1 << 8;
  static const floorChangeNorth = 1 << 9;
  static const floorChangeEast = 1 << 10;
  static const floorChangeSouth = 1 << 11;
  static const floorChangeWest = 1 << 12;
  static const stackOrder = 1 << 13;
  static const readable = 1 << 14;
  static const rotatable = 1 << 15;
  static const hangable = 1 << 16;
  static const hookSouth = 1 << 17;
  static const hookEast = 1 << 18;
  static const canNotDecay = 1 << 19;
  static const allowDistanceRead = 1 << 20;
  static const unused = 1 << 21;
  static const clientCharges = 1 << 22;
  static const ignoreLook = 1 << 23;
  static const isAnimation = 1 << 24;
  static const fullGround = 1 << 25;
  static const forceUse = 1 << 26;
}

abstract class _OtbItemAttribute {
  static const serverId = 0x10;
  static const clientId = 0x11;
  static const name = 0x12;
  static const groundSpeed = 0x14;
  static const spriteHash = 0x20;
  static const minimapColor = 0x21;
  static const maxReadWriteChars = 0x22;
  static const maxReadChars = 0x23;
  static const light = 0x2A;
  static const stackOrder = 0x2B;
  static const tradeAs = 0x2D;
}
