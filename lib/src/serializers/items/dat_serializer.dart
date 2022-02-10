import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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

    List<DatItem> items = [];

    for (int i = 0; i < itemsCount; i++) {
      bool stackable = false;
      bool splash = false;
      bool fluidContainer = false;
      int? minimapColor;

      int byte = dat.getUint8();
      while (byte != 0xFF) {
        if (byte == 0x05) {
          stackable = true;
        } else if (byte == 0x0C) {
          splash = true;
        } else if (byte == 0x0B) {
          fluidContainer = true;
        } else if (byte == 0x1D) {
          minimapColor = dat.getUint16(endian: Endian.little);
        } else if ([0x00, 0x09, 0x0A, 0x1A, 0x1E].contains(byte)) {
          // TODO: handle these properties
          dat.getUint16();
        } else if ([0x16, 0x19].contains(byte)) {
          // TODO: handle these properties
          dat.getUint32();
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

      for (int j = 0; i < spritesCount; j++) {
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
        stackable: stackable,
        splash: splash,
        fluidContainer: fluidContainer,
        textures: textures,
      );
      items.add(item);
      tracker.progress = (i + 1) / itemsCount;
    }

    return DatDocument(signature: signature, items: items);
  }
}

class DatDocument {
  final int signature;
  final List<DatItem> items;

  DatDocument({required this.signature, required this.items});
}

class DatItem {
  final int id;
  final int? minimapColor;
  final bool stackable;
  final bool splash;
  final bool fluidContainer;
  final DatTextures textures;

  DatItem(
      {required this.id,
      this.minimapColor,
      required this.stackable,
      required this.splash,
      required this.fluidContainer,
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
