import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'dart:ui' as ui;
import 'dart:async';

const SPRITE_SIZE = 32;
const SPRITE_BYTES = SPRITE_SIZE * SPRITE_SIZE * 4;

class ItemsLoaderPayload {
  final String itemsFilePath;
  final String sprFilePath;
  final String datFilePath;
  final SendPort sendPort;

  ItemsLoaderPayload(
      {this.itemsFilePath, this.sprFilePath, this.datFilePath, this.sendPort});
}

class ItemsLoaderProgress {
  double spritesProgress = 0;
  double itemsProgress = 0;

  ItemsLoaderProgress({this.spritesProgress, this.itemsProgress});
}

class ItemsLoader {
  static Sprite getSprite(bytes, offset, id) {
    // print('startOffset: ' + startOffset.toString());
    // print('offset: ' + offsets[id].toString());
    // if (offset == 0) {
    //   return;
    // }

    ReadBuffer spr =
        ReadBuffer(ByteData.sublistView(bytes.buffer.asUint8List(), offset));
    spr.getUint8();
    spr.getUint8();
    spr.getUint8();
    // spr.getUint16();
    int coloredBytesCount = spr.getUint16(endian: Endian.little);
    // print('coloredBytesCount: ' + coloredBytesCount.toString());
    int bytesPut = 0;
    int coloredBytesPut = 0;
    WriteBuffer pixels = WriteBuffer();
    while (coloredBytesPut < coloredBytesCount && bytesPut < SPRITE_BYTES) {
      int transparentPixels = spr.getUint16(endian: Endian.little);
      // print('transparent: ' + transparentPixels.toString());
      for (int j = 0; j < transparentPixels && bytesPut < SPRITE_BYTES; j++) {
        pixels.putUint32(0);
        bytesPut += 4;
      }
      int coloredPixels = spr.getUint16(endian: Endian.little);
      // print('colored: ' + coloredPixels.toString());
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
    // print('pixelsPadding: ' + pixelsPadding.toString());
    if (bytesPadding > 0) {
      pixels.putUint8List(Uint8List(bytesPadding));
    }
    Uint8List pixelsList = pixels.done().buffer.asUint8List();
    // print('pixelss.length after: ' + (pixelsList.length / 4).toString());
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
    // print('gUI1');
    ui.Codec codec = await ui.instantiateImageCodec(bitmap,
        targetWidth: SPRITE_SIZE, targetHeight: SPRITE_SIZE);
    // print('gUI2');
    ui.FrameInfo fi = await codec.getNextFrame();
    // print('gUI3');
    return fi.image;

    // print('gUI1');
    // ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    // print('gUI2');
    // ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(buffer,
    //     width: SPRITE_SIZE,
    //     height: SPRITE_SIZE,
    //     pixelFormat: ui.PixelFormat.rgba8888);
    // print('gUI3');
    // ui.Codec codec = await descriptor.instantiateCodec();
    // print('gUI4');
    // ui.FrameInfo frameInfo = await codec.getNextFrame();
    // print('gUI5');
    // ui.Image image = frameInfo.image;
    // print('gUI6');
    // return image;
    // return decodeImageFromList(bitmap);
    // Completer completer = new Completer();
    // ui.decodeImageFromList(bitmap, (ui.Image image) {
    //   if (image != null) {
    //     completer.complete(image);
    //   } else {
    //     completer.completeError(null);
    //   }
    // });
    // return completer.future;
  }

  static Future<Item> getItem(int id, Sprite sprite) async {
    Uint8List bitmap = getHeadedBitmap(sprite);
    Image image = getImage(bitmap);
    // print('ui1');
    ui.Image uiImage = await getUiImage(sprite.pixels);
    // print('ui2');
    return Item(id: id, spriteId: sprite.id, image: image, uiImage: uiImage);
  }

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
    // int startOffset = 0; // 6 + spritesCount * 4;

    // print('sprites offsets length: ' + offsets.length.toString());
    // print('offsets[0] sprite');

    // for (int i = 100; i < 130; i++) {
    //   print('spritee');
    //   Sprite sprite = ItemsLoader.getSprite(sprBytes, startOffset, offsets, i);
    //   items.add(ItemsLoader.getItem(sprite));
    // }

    //   ReadBuffer spr = ReadBuffer(ByteData.sublistView(
    //       sprBytes.buffer.asUint8List(), startOffset + offsets[i]));
    //   spr.getUint8();
    //   spr.getUint8();
    //   spr.getUint8();
    //   // spr.getUint8();
    //   int spriteSize = spr.getUint16(endian: Endian.little);
    //   // print('spriteSize' + spriteSize.toString());
    //   int pixelsParsed = 0;
    //   WriteBuffer pixels = WriteBuffer();
    //   while (pixelsParsed < spriteSize) {
    //     // stdout.writeln('pixelsParsed: ' +
    //     //     pixelsParsed.toString() +
    //     //     ', spriteSize: ' +
    //     //     spriteSize.toString());
    //     int transparentPixels = spr.getUint16(endian: Endian.little);
    //     pixels.putUint8List(Uint8List(transparentPixels));
    //     int coloredPixels = spr.getUint16(endian: Endian.little);
    //     // print('transparent ' + transparentPixels.toString());
    //     // print('colored ' + coloredPixels.toString());
    //     for (int j = 0; j < coloredPixels; j++) {
    //       pixels.putUint8(spr.getUint8());
    //       pixels.putUint8(spr.getUint8());
    //       pixels.putUint8(spr.getUint8());
    //       pixels.putUint8(0xFF);
    //     }
    //     // print('bbb');
    //     pixelsParsed += transparentPixels + coloredPixels;
    //   }
    //   // print('zzz');
    //   sprites.add(Sprite(i + 2, pixels.done().buffer.asUint8List()));
    // }
    // print('ItemsLoader.load10');
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
      int blendFrames = dat.getUint8();
      int divX = dat.getUint8();
      int divY = dat.getUint8();
      int divZ = dat.getUint8();
      int animationLength = dat.getUint8();
      // print('blendFrames: ' + blendFrames.toString());
      // print('divX: ' + divX.toString());
      // print('divY: ' + divY.toString());
      // print('divZ: ' + divZ.toString());
      // print('animationLength: ' + animationLength.toString());
      int spritesCount =
          width * height * blendFrames * divX * divY * divZ * animationLength;
      List<Uint8List> itemSprites = List.empty(growable: true);
      // print('item i ' + i.toString());
      // print('spritesCount ' + spritesCount.toString());

      Sprite firstSprite;

      for (int j = 0; j < spritesCount; j++) {
        // print('dat5');
        int spriteId = dat.getUint16(endian: Endian.little);
        print('i ' + i.toString() + ', spriteId ' + spriteId.toString());

        // Sprite sprite = sprites.firstWhere((sprite) => sprite.id == spriteId);

        Sprite sprite = (spriteId < 2 || spriteId > sprites.length + 2)
            ? sprites.first
            : sprites.firstWhere((s) => s.id == spriteId);

        if (sprite == null) {
          sprite = sprites.first;
        }

        // if (spriteId >= 2 && spriteId <= sprites.length + 2) {
        // Sprite sprite = sprites.firstWhere((s) => s.id == spriteId);

        // if (sprite == null) {
        //   sprite = sprites.first;
        // }

        Uint8List bitmap = getHeadedBitmap(sprite);
        itemSprites.add(bitmap);

        // Sprite sprite = ItemsLoader.getSprite(sprBytes, offsets[spriteId]);
        if (j == 0) {
          // if (spriteId >= 2 && spriteId <= sprites.length + 2) {
          // print('sprite id ' + spriteId.toString());
          // print('sprites length ' + sprites.length.toString());
          // print('sprites index' + (spriteId - 2).toString());
          // Sprite sprite = sprites.elementAt(spriteId - 2);
          // Sprite sprite = sprites.firstWhere((s) => s.id == spriteId);
          // print('sprite ' + spriteId.toString() + ': ' + sprite.toString());
          // if (sprite != null) {
          // print('image ' + image.toString());
          // Uint8List bitmap = getHeadedBitmap(sprite);
          // Image image = getImage(bitmap);
          // try {
          // ui.Image uiImage = await getUiImage(bitmap);
          // print('ui1');
          // ui.Image uiImage = await getUiImage(sprite.pixels);
          // print('ui2');
          firstSprite = Sprite(spriteId, bitmap);
          // items.add(Item(id: i + 100, spriteId: sprite.id, bitmap: bitmap));
          // image: image,
          // uiImage: uiImage));
          // } catch (err) {
          //   print('err: ' + err.toString());
          // }
          // itemsFutures.add(getItem(i + 100, sprite));
          // }
          // }
        }
        // }

        //     spriteId); // sprites.firstWhere((sprite) => sprite.id == spriteId);
        // itemSprites.add(sprite);
        // items.add(Item(
        //     id: i + 100,
        //     spriteId: spriteId,
        //     image: ItemsLoader.getImage(sprite)));
        // image: ItemsLoader.getImage(sprite)));
      }

      if (firstSprite != null) {
        items.add(Item(
            id: i + 100,
            name:
                'spritesCount $spritesCount, width $width, height $height, blendFrames $blendFrames, divX $divX, divY $divY, divZ $divZ, animationLength $animationLength',
            spriteId: firstSprite.id,
            bitmap: firstSprite.pixels,
            sprites: itemSprites));
      }

      progress.itemsProgress = (i + 1) / itemsCount / 2;
      sendPort.send(progress);
    }

    // print('future.wait');

    // List<Item> items = await Future.wait(itemsFutures);

    //   // for (int i = 0; i < offsets.length; i++) {
    //   //   Item item = items.firstWhere((item) => item.spriteId == i);
    //   //   if (item != null) {
    //   //     Sprite sprite = ItemsLoader.getSprite(sprBytes, offsets[i]);
    //   //     if (sprite != null) {
    //   //       item.image = ItemsLoader.getImage(sprite);
    //   //     }
    //   //   }
    //   // }
    print('loaded?');

    //   // print('dat6');
    //   // stdout.writeln('ItemsLoader.load20');
    //   // print('itemSprites.length: ' + itemSprites.length.toString());
    //   // Sprite itemSprite = itemSprites[0];
    //   // print('itemSprite.pixels.length: ' + itemSprite.pixels.length.toString());

    //   //   // ui.decodeImageFromPixels(
    //   //   //     itemSprite.pixels, SPRITE_SIZE, SPRITE_SIZE, ui.PixelFormat.rgba8888,
    //   //   //     (image) async {
    //   //   //   print('items.add1');
    //   //   //   ByteData imagePng =
    //   //   //       await image.toByteData(format: ui.ImageByteFormat.png);
    //   //   //   print('items.add2');
    //   //   //   items.add(Item(
    //   //   //       id: itemSprite.id,
    //   //   //       image: Image.memory(imagePng.buffer.asUint8List())));
    //   //   // });
    //   //   // items.add(Item(
    //   //   //     id: i + 100,
    //   //   //     image: Image.memory(itemSprites[0]
    //   //   //         .pixels
    //   //   //         .expand((element) => element)
    //   //   //         .toList()))); // TODO: merge multiple sprites
    // }
    // print('sprites length ' + sprites.length.toString());
    // List<Item> items = List.empty(growable: true);
    // for (int i = 0; i < sprites.length; i++) {
    //   print('pixels length ' + sprites[0].pixels.length.toString());
    //   print('items.add0');
    //   ui.decodeImageFromPixels(
    //       sprites[i].pixels, SPRITE_SIZE, SPRITE_SIZE, ui.PixelFormat.rgba8888,
    //       (image) async {
    //     print('items.add1');
    //     ByteData imagePng =
    //         await image.toByteData(format: ui.ImageByteFormat.png);
    //     print('items.add2');
    //     items.add(Item(
    //         id: sprites[i].id,
    //         image: Image.memory(imagePng.buffer.asUint8List())));
    //   });

    //   print('items.add');
    // }
    // print('ItemLoader.load21');
    // print('items: ' + items.toString());
    return items;
  }
}
