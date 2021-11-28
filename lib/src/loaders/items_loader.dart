import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/editor/map.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:image/image.dart' as img;
import '../models/texture.dart' as t;

const SPRITE_SIZE = 32;
const SPRITE_BYTES = SPRITE_SIZE * SPRITE_SIZE * 4;

class ItemsLoaderPayload {
  final String itemsFilePath;
  final String sprFilePath;
  final String datFilePath;
  final SendPort sendPort;

  ItemsLoaderPayload(
      {required this.itemsFilePath,
      required this.sprFilePath,
      required this.datFilePath,
      required this.sendPort});
}

class ItemsLoaderProgress {
  double spritesProgress;
  double itemsProgress;

  ItemsLoaderProgress({this.spritesProgress = 0, this.itemsProgress = 0});
}

class ItemsLoader {
  static Sprite getSprite(bytes, offset, id) {
    ReadBuffer spr =
        ReadBuffer(ByteData.sublistView(bytes.buffer.asUint8List(), offset));
    spr.getUint8();
    spr.getUint8();
    spr.getUint8();
    int coloredBytesCount = spr.getUint16(endian: Endian.little);
    int bytesPut = 0;
    int coloredBytesPut = 0;
    WriteBuffer pixels = WriteBuffer();
    while (coloredBytesPut < coloredBytesCount && bytesPut < SPRITE_BYTES) {
      int transparentPixels = spr.getUint16(endian: Endian.little);
      for (int j = 0; j < transparentPixels && bytesPut < SPRITE_BYTES; j++) {
        pixels.putUint32(0);
        bytesPut += 4;
      }
      int coloredPixels = spr.getUint16(endian: Endian.little);
      for (int j = 0; j < coloredPixels && bytesPut < SPRITE_BYTES; j++) {
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(0xFF);
        bytesPut += 4;
      }
      coloredBytesPut += 4 + 3 * coloredPixels;
    }
    int bytesPadding = SPRITE_BYTES - bytesPut;
    if (bytesPadding > 0) {
      pixels.putUint8List(Uint8List(bytesPadding));
    }
    Uint8List pixelsList = pixels.done().buffer.asUint8List();
    return Sprite(id, pixelsList.sublist(0, SPRITE_BYTES));
  }

  static Uint8List getHeadedBitmap(sprite) {
    Bitmap bitmap =
        Bitmap.fromHeadless(SPRITE_SIZE, SPRITE_SIZE, sprite.pixels);
    return bitmap.buildHeaded();
  }

  static Image getImage(Uint8List bitmap) {
    return Image.memory(bitmap);
  }

  static Future<ui.Image> getUiImage(Uint8List bitmap) async {
    ui.Codec codec = await ui.instantiateImageCodec(bitmap,
        targetWidth: SPRITE_SIZE, targetHeight: SPRITE_SIZE);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  // static Future<Item> getItem(int id, Sprite sprite) async {
  //   Uint8List bitmap = getHeadedBitmap(sprite);
  //   Image image = getImage(bitmap);
  //   // print('ui1');
  //   ui.Image uiImage = await getUiImage(sprite.pixels);
  //   // print('ui2');
  //   // return Item(id: id, spriteId: sprite.id, image: image, uiImage: uiImage);
  //   return Item(id: id, textures: Lis t.Texture(sprite.pixels));
  // }

  static Future<List<Item>> load(ItemsLoaderPayload payload) async {
    // String itemsFilePath = payload.itemsFilePath;
    String sprFilePath = payload.sprFilePath;
    String datFilePath = payload.datFilePath;
    SendPort sendPort = payload.sendPort;
    ItemsLoaderProgress progress = ItemsLoaderProgress();

    stdout.writeln('ItemsLoader.load1');
    Uint8List sprBytes = await File(sprFilePath).readAsBytes();
    stdout.writeln('ItemsLoader.load2');
    ReadBuffer spr = ReadBuffer(ByteData.view(sprBytes.buffer));
    spr.getUint32(); // SPR signature
    int spritesCount = spr.getUint16(endian: Endian.little);
    print('spritesCount' + spritesCount.toString());
    List<Sprite> sprites = List.empty(growable: true);
    stdout.writeln('ItemsLoader.load3');
    List<int> offsets = List.empty(growable: true);

    for (int i = 0; i < spritesCount; i++) {
      int offset = spr.getUint32(endian: Endian.little);
      // if (i < 10) {
      // if (i == 1) {
      int offset2 = offset; // + 6 + (i * 4);
      // print('offset: ' + offset2.toString());
      if (offset2 != 0) {
        Sprite sprite = ItemsLoader.getSprite(sprBytes, offset2, i + 1);
        // print('sprites index: ' +
        //     sprites.length.toString() +
        //     ', spriteId: ' +
        //     (i + 1).toString());
        sprites.add(sprite);
        // items.add(Item(
        //     id: i + 1, spriteId: i + 1, image: ItemsLoader.getImage(sprite)));
      }
      progress.spritesProgress = (i + 1) / spritesCount;
      sendPort.send(progress);
      // }
      // offsets.add(offset);
    }

    Uint8List datBytes = await File(datFilePath).readAsBytes();
    ReadBuffer dat = ReadBuffer(ByteData.view(datBytes.buffer));
    dat.getUint32(); // DAT signature
    int itemsCount = dat.getUint16(endian: Endian.little);
    int outfitsCount = dat.getUint16(endian: Endian.little);
    int effectsCount = dat.getUint16(endian: Endian.little);
    int distanceEffectsCount = dat.getUint16(endian: Endian.little);
    print('itemsCount: ' + itemsCount.toString());

    List<Item> items = List.empty(growable: true);

    for (int i = 0; i < itemsCount; i++) {
      int byte = dat.getUint8();
      // print('byte ' + byte.toString());
      while (byte != 0xFF) {
        if ([0x00, 0x09, 0x0A, 0x1A, 0x1D, 0x1E].contains(byte)) {
          dat.getUint16();
        } else if ([0x16, 0x19].contains(byte)) {
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
      int patterns_x = dat.getUint8();
      int patterns_y = dat.getUint8();
      int patterns_z = dat.getUint8();
      int frames = dat.getUint8();

      // List<Sprite> itemSprites = List.empty(growable: true);
      List<t.Texture> textures = List.empty(growable: true);

      for (int frame = 0; frame < frames; frame++) {
        for (int pattern_z = 0; pattern_z < patterns_z; pattern_z++) {
          for (int pattern_y = 0; pattern_y < patterns_y; pattern_y++) {
            for (int pattern_x = 0; pattern_x < patterns_x; pattern_x++) {
              img.Image texture =
                  img.Image(width * TILE_SIZE, height * TILE_SIZE);
              for (int layer = 0; layer < layers; layer++) {
                for (int h = 0; h < height; h++) {
                  for (int w = 0; w < width; w++) {
                    int spriteId = dat.getUint16(endian: Endian.little);
                    print('spriteId $spriteId');
                    Sprite? sprite =
                        (spriteId >= 2 && spriteId <= sprites.length + 2)
                            ? sprites.firstWhere((s) => s.id == spriteId)
                            : null;
                    if (sprite != null) {
                      img.copyInto(
                        texture,
                        img.Image.fromBytes(
                            TILE_SIZE, TILE_SIZE, sprite.pixels),
                        dstX: (width - w - 1) * TILE_SIZE,
                        dstY: (height - h - 1) * TILE_SIZE,
                      );
                    }
                  }
                }
              }

              Bitmap bitmap = Bitmap.fromHeadless(
                  texture.width, texture.height, texture.getBytes());
              Uint8List headed = bitmap.buildHeaded();
              textures.add(t.Texture(
                width: texture.width,
                height: texture.height,
                bitmap: headed,
              ));
            }
          }
        }
      }

      items.add(Item(
        id: i + 100,
        name:
            'spritesCount $spritesCount, width $width, height $height, layers $layers, patterns x $patterns_x, patterns y $patterns_y, patterns z $patterns_z, frames $frames',
        textures: textures,
      ));

      progress.itemsProgress = (i + 1) / itemsCount / 2;
      sendPort.send(progress);
    }

    return items;
  }
}
