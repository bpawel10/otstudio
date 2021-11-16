import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/sprite.dart';

const SPRITE_SIZE = 32;

class ItemsLoader {
  static Sprite getSprite(bytes, startOffset, offsets, id) {
    // print('startOffset: ' + startOffset.toString());
    // print('offset: ' + offsets[id].toString());
    ReadBuffer spr = ReadBuffer(ByteData.sublistView(
        bytes.buffer.asUint8List(), startOffset + offsets[id]));
    spr.getUint8();
    spr.getUint8();
    spr.getUint8();
    spr.getUint16();
    int spriteSize =
        pow(SPRITE_SIZE, 2); // spr.getUint16(endian: Endian.little);
    // print('spriteSize: ' + spriteSize.toString());
    int pixelsPut = 0;
    WriteBuffer pixels = WriteBuffer();
    while (pixelsPut < spriteSize) {
      int transparentPixels = spr.getUint16(endian: Endian.little);
      // print('transparent: ' + transparentPixels.toString());
      pixels.putUint8List(Uint8List(transparentPixels * 4));
      int coloredPixels = spr.getUint16(endian: Endian.little);
      // print('colored: ' + coloredPixels.toString());
      for (int j = 0; j < coloredPixels; j++) {
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(0xFF);
      }
      pixelsPut += transparentPixels + coloredPixels;
    }
    int pixelsPadding = pow(SPRITE_SIZE, 2) - pixelsPut;
    // print('pixelsPadding: ' + pixelsPadding.toString());
    if (pixelsPadding > 0) {
      pixels.putUint8List(Uint8List(pixelsPadding * 4));
    }
    Uint8List pixelsList = pixels.done().buffer.asUint8List();
    // print('pixelss.length after: ' + (pixelsList.length / 4).toString());
    return Sprite(id, pixelsList);
  }

  static Image getImage(sprite) {
    Bitmap bitmap =
        Bitmap.fromHeadless(SPRITE_SIZE, SPRITE_SIZE, sprite.pixels);
    Image image = Image.memory(bitmap.buildHeaded());
    return image;
  }

  static Future<List<Item>> load(
      itemsFilePath, sprFilePath, datFilePath) async {
    // File itemsFile = File(itemsFilePath).readAsS
    stdout.writeln('ItemsLoader.load1');
    Uint8List sprBytes = await File(sprFilePath).readAsBytes();
    stdout.writeln('ItemsLoader.load2');
    ReadBuffer spr = ReadBuffer(ByteData.view(sprBytes.buffer));
    spr.getUint32(); // SPR signature
    int spritesCount = spr.getUint16(endian: Endian.little);
    print('spritesCount' + spritesCount.toString());
    List<Sprite> sprites = [];
    stdout.writeln('ItemsLoader.load3');
    List<int> offsets = [];
    for (int i = 0; i < spritesCount; i++) {
      offsets.add(spr.getUint32(endian: Endian.little));
    }
    int startOffset = 0; // 6 + spritesCount * 4;

    List<Item> items = List.empty(growable: true);

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
    for (int i = 0; i < 1000; i++) {
      int byte;
      // print('dat2');
      do {
        byte = dat.getUint8();
      } while (byte != 0xFF);
      // print('dat3');
      int width = dat.getUint8();
      int height = dat.getUint8();
      // print('width: ' + width.toString());
      // print('height: ' + height.toString());
      if (width > 1 || height > 1) {
        dat.getUint8();
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
      List<Sprite> itemSprites = [];
      // print('dat4');
      for (int j = 0; j < spritesCount; j++) {
        // print('dat5');
        int spriteId = dat.getUint16(endian: Endian.little);
        // print('dat6 ' + spriteId.toString());
        Sprite sprite = ItemsLoader.getSprite(sprBytes, startOffset, offsets,
            spriteId); // sprites.firstWhere((sprite) => sprite.id == spriteId);
        // itemSprites.add(sprite);
        items.add(Item(
            id: i + 100,
            spriteId: sprite.id,
            image: ItemsLoader.getImage(sprite)));
      }
      // print('dat6');
      // stdout.writeln('ItemsLoader.load20');
      // print('itemSprites.length: ' + itemSprites.length.toString());
      // Sprite itemSprite = itemSprites[0];
      // print('itemSprite.pixels.length: ' + itemSprite.pixels.length.toString());

      //   // ui.decodeImageFromPixels(
      //   //     itemSprite.pixels, SPRITE_SIZE, SPRITE_SIZE, ui.PixelFormat.rgba8888,
      //   //     (image) async {
      //   //   print('items.add1');
      //   //   ByteData imagePng =
      //   //       await image.toByteData(format: ui.ImageByteFormat.png);
      //   //   print('items.add2');
      //   //   items.add(Item(
      //   //       id: itemSprite.id,
      //   //       image: Image.memory(imagePng.buffer.asUint8List())));
      //   // });
      //   // items.add(Item(
      //   //     id: i + 100,
      //   //     image: Image.memory(itemSprites[0]
      //   //         .pixels
      //   //         .expand((element) => element)
      //   //         .toList()))); // TODO: merge multiple sprites
    }
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
