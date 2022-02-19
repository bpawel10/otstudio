import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/progress_tracker.dart';

class DatSerializer extends DiskSerializer<DatDocument> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload> tracker) {
    // TODO: implement serialize
    throw UnimplementedError();
  }

  @override
  Future<DatDocument> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) async {
    Uint8List bytes = await File(tracker.data.path).readAsBytes();
    ReadBuffer dat = ReadBuffer(ByteData.view(bytes.buffer));
    int signature = dat.getUint32();

    int itemsCount = dat.getUint16(endian: Endian.little);
    int outfitsCount = dat.getUint16(endian: Endian.little);
    int effectsCount = dat.getUint16(endian: Endian.little);
    int distanceEffectsCount = dat.getUint16(endian: Endian.little);

    // TODO: handle outfits, effects and distances

    Map<int, DatItem> items = Map();

    for (int i = 0; i < itemsCount; i++) {
      bool ground = false;
      bool stackable = false;
      bool splash = false;
      bool fluidContainer = false;
      Offset drawOffset = Offset.zero;
      Offset heightOffset = Offset.zero;
      int? minimapColor;

      int byte = dat.getUint8();
      while (byte != _DatSpecialCharacter.flagsEnd) {
        if (byte == _DatItemFlag.stackable) {
          stackable = true;
        } else if (byte == _DatItemFlag.splash) {
          splash = true;
        } else if (byte == _DatItemFlag.fluidContainer) {
          fluidContainer = true;
        } else if (byte == _DatItemFlag.minimapColor) {
          minimapColor = dat.getUint16(endian: Endian.little);
        } else if (byte == _DatItemFlag.height) {
          double height = dat.getUint16(endian: Endian.little).toDouble();
          heightOffset = Offset(height, height);
        } else if (byte == _DatItemFlag.ground) {
          int speed = dat.getUint16(endian: Endian.little);
          ground = true;
        } else if ([
          _DatItemFlag.writeable,
          _DatItemFlag.readable,
          _DatItemFlag.height,
          _DatItemFlag.floorChange,
        ].contains(byte)) {
          // TODO: handle these properties
          dat.getUint16();
        } else if (byte == _DatItemFlag.lightInfo) {
          // TODO: handle this property
          dat.getUint32();
        } else if (byte == _DatItemFlag.drawOffset) {
          drawOffset = Offset(dat.getUint16(endian: Endian.little).toDouble(),
              dat.getUint16(endian: Endian.little).toDouble());
        }
        byte = dat.getUint8();
        // print('byte ' + byte.toString());
      }

      // print('dat3');
      int width = dat.getUint8();
      int height = dat.getUint8();
      // print('width: ' + width.toString());
      // print('height: ' + height.toString());
      if (width > 1 || height > 1) {
        dat.getUint8(); // TODO: check in rme/otclient code maybe we can find what this byte contains
      }
      int layers = dat.getUint8();
      int patternsX = dat.getUint8();
      int patternsY = dat.getUint8();
      int patternsZ = dat.getUint8();
      int frames = dat.getUint8();

      int spritesCount =
          width * height * layers * patternsX * patternsY * patternsZ * frames;

      List<int> sprites = [];

      for (int j = 0; j < spritesCount; j++) {
        sprites.add(dat.getUint16(endian: Endian.little));
      }

      DatTextures textures = DatTextures(
          width: width,
          height: height,
          layers: layers,
          patternsX: patternsX,
          patternsY: patternsY,
          patternsZ: patternsZ,
          frames: frames,
          sprites: sprites);

      int id = i + 100;

      DatItem item = DatItem(
        id: id,
        minimapColor: minimapColor,
        ground: ground,
        stackable: stackable,
        splash: splash,
        fluidContainer: fluidContainer,
        drawOffset: drawOffset,
        heightOffset: heightOffset,
        textures: textures,
      );
      items[item.id] = item;
      tracker.progress = (i + 1) / itemsCount;
    }

    return DatDocument(signature: signature, items: items);
  }
}

class DatDocument {
  final int signature;
  final Map<int, DatItem> items;

  DatDocument({required this.signature, required this.items});
}

class DatItem {
  final int id;
  final int? minimapColor;
  final bool ground;
  final bool stackable;
  final bool splash;
  final bool fluidContainer;
  final Offset drawOffset;
  final Offset heightOffset;
  final DatTextures textures;

  DatItem(
      {required this.id,
      this.minimapColor,
      required this.ground,
      required this.stackable,
      required this.splash,
      required this.fluidContainer,
      required this.drawOffset,
      required this.heightOffset,
      required this.textures});
}

class DatTextures {
  final int width;
  final int height;
  final int layers;
  final int patternsX;
  final int patternsY;
  final int patternsZ;
  final int frames;
  final List<int> sprites;

  DatTextures(
      {required this.width,
      required this.height,
      required this.layers,
      required this.patternsX,
      required this.patternsY,
      required this.patternsZ,
      required this.frames,
      required this.sprites});
}

abstract class _DatSpecialCharacter {
  static const flagsEnd = 0xFF;
}

abstract class _DatItemFlag {
  static const ground = 0x00;
  static const onTop = 0x01;
  static const walkThroughDoors = 0x02;
  static const walkThroughArches = 0x03;
  static const container = 0x04;
  static const stackable = 0x05;
  static const ladder = 0x06;
  static const usable = 0x07;
  static const rune = 0x08;
  static const writeable = 0x09;
  static const readable = 0x0A;
  static const fluidContainer = 0x0B;
  static const splash = 0x0C;
  static const blocking = 0x0D;
  static const immoveable = 0x0E;
  static const blocksMissile = 0x0F;
  static const blocksMonsterMovement = 0x10;
  static const equipable = 0x11;
  static const hangable = 0x12;
  static const horizontal = 0x13;
  static const vertical = 0x14;
  static const rotateable = 0x15;
  static const lightInfo = 0x16;
  static const unknown1 = 0x17;
  static const floorChangeDown = 0x18;
  static const drawOffset = 0x19;
  static const height = 0x1A;
  static const drawWithHeightOffsetForAllParts = 0x1B;
  static const lifeBarOffset = 0x1C;
  static const minimapColor = 0x1D;
  static const floorChange = 0x1E;
  static const unknown2 = 0x1F;
}
