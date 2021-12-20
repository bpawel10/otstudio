import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/editor/map.dart' as m;
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:image/image.dart' as img;
import '../models/texture.dart' as t;
import 'dart:math';
import '../models/atlas.dart';

const SPRITE_SIZE = 32;
const SPRITE_BYTES = SPRITE_SIZE * SPRITE_SIZE * 4;

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

class ItemsLoaderPayload {
  // final String itemsFilePath;
  final String otbFilePath;
  final String xmlFilePath;
  final String sprFilePath;
  final String datFilePath;
  final SendPort sendPort;

  ItemsLoaderPayload(
      { // required this.itemsFilePath,
      required this.otbFilePath,
      required this.xmlFilePath,
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

  static Future<ui.Image> getUiImage(Uint8List bitmap,
      {int width = SPRITE_SIZE, int height = SPRITE_SIZE}) async {
    ui.Codec codec = await ui.instantiateImageCodec(bitmap,
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  static Future<Atlas> getAtlas(List<Item> items) async {
    List<Item> items2 = items.take(10).toList();
    // List<Item> items2 = items.toList();

    int atlasWidth = 0;
    int atlasHeight = 0;

    items2.forEach((item) {
      atlasWidth += item.textures[0].width;
      atlasHeight = max(atlasHeight, item.textures[0].height);
    });

    Map<int, ui.Rect> rects = Map();

    print('atlasWidth $atlasWidth atlasHeight $atlasHeight');

    img.Image atlasImg = img.Image(atlasWidth, atlasHeight);

    int atlasPos = 0;

    items2.asMap().forEach((index, item) {
      print('atlasPos $atlasPos');

      t.Texture texture = item.textures[0];
      // ByteData? byteData = await texture.bitmap

      img.copyInto(atlasImg,
          img.Image.fromBytes(texture.width, texture.height, texture.bytes),
          // Bitmap.fromHeadful(texture.width, texture.height, texture.bitmap)
          //     .content),
          dstX: atlasPos,
          dstY: atlasHeight - texture.height);
      rects[item.id] = Offset(
              atlasPos.toDouble(), (atlasHeight - texture.height).toDouble()) &
          Size(texture.width.toDouble(), texture.height.toDouble());
      atlasPos += texture.width;
    });

    Bitmap atlasBitmap =
        Bitmap.fromHeadless(atlasWidth, atlasHeight, atlasImg.getBytes());

    print('atlasBitmap $atlasBitmap');

    ui.Image atlasUiImage = await ItemsLoader.getUiImage(
        atlasBitmap.buildHeaded(),
        width: atlasWidth,
        height: atlasHeight);

    Atlas atlas = Atlas(atlas: atlasUiImage, rects: rects);

    // print(
    //     'atlasUiImage width ${atlasUiImage.width} height ${atlasUiImage.height} bytes ${atlas.getBytes()}');

    return atlas;
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

  static Future<Map<int, Item>> loadOtbItems(String path) async {
    Uint8List otbBytes = await File(path).readAsBytes();

    // ReadBuffer otb = ReadBuffer(ByteData.view(otbBytes.buffer));
    _OtbNode otb = _OtbNode(otbBytes.sublist(4));

    // print('otb.node ${otb._node}');
    // print('otb.node.length ${otb._node!.data.lengthInBytes}');
    // print('otb.node.data ${otb._node!.data}');
    // print('otb.children length ${otb.children.length}');

    // otb.node.getUint32(endian: Endian.little); // 4 zeros, not sure why
    // otb.node.getUint8(); // root node, 0xFE
    otb.getUint8(); // first byte of otb is 0
    otb.getUint32(); // 4 bytes flags, unused

    int attr0 = otb.getUint8();
    // print('attr0 $attr0');
    if (attr0 == 0x01) {
      // rootattribute.version
      int dataLength = otb.getUint16();
      int majorVersion = otb.getUint32();
      int minorVersion = otb.getUint32();
      int buildVersion = otb.getUint32();
      // print('majorVersion $majorVersion minorVersion $minorVersion buildVersion $buildVersion');
      otb.getUint8List(dataLength - 3 * 4);
    }

    List<_OtbNode> itemNodes = otb.children;
    Map<int, Item> otbItems = Map();

    itemNodes.forEach((itemNode) {
      // print('itemNode ${itemNode._node!.data.buffer.asUint8List().toList()}');
      int itemGroup = itemNode.getUint8();
      int flags = itemNode.getUint32();
      bool stackable =
          (flags & _OtbItemFlag.stackable) == _OtbItemFlag.stackable;
      bool splash = itemGroup == _OtbItemType.splash;
      bool fluidContainer = itemGroup == _OtbItemType.fluid;

      int serverId = 0;
      int clientId = 0;
      String name = '';
      // int groundSpeed;
      // int spriteHash;
      // int minimapColor;
      // int maxReadWriteChars;
      // int maxReadChars;
      // int light;
      // int stackOrder;
      // int tradeAs;

      while (itemNode.hasRemaining) {
        int attr = itemNode.getUint8();
        // print('attr $attr');

        int dataLength = itemNode.getUint16();

        switch (attr) {
          case _OtbItemAttribute.serverId:
            serverId = itemNode.getUint16();
            // read += 2;
            break;
          case _OtbItemAttribute.clientId:
            clientId = itemNode.getUint16();
            // read += 2;
            break;
          case _OtbItemAttribute.name:
            int length = itemNode.getUint16();
            name = String.fromCharCodes(itemNode.getUint8List(length));
            // read += 2 + length;
            break;
          case _OtbItemAttribute.groundSpeed:
            int groundSpeed = itemNode.getUint16();
            // read += 2;
            break;
          case _OtbItemAttribute.spriteHash:
            // print('sprite hash of length $dataLength');
            Uint8List spriteHash = itemNode.getUint8List(dataLength);
            break;
          case _OtbItemAttribute.minimapColor:
            int minimapColor = itemNode.getUint16();
            break;
          case _OtbItemAttribute.maxReadWriteChars:
            int maxReadWriteChars = itemNode.getUint16();
            break;
          case _OtbItemAttribute.maxReadChars:
            int maxReadChars = itemNode.getUint16();
            break;
          case _OtbItemAttribute.light:
            int lightLevel = itemNode.getUint16();
            int lightColor = itemNode.getUint16();
            break;
          case _OtbItemAttribute.stackOrder:
            int stackOrder = itemNode.getUint8();
            break;
          case _OtbItemAttribute.tradeAs:
            int tradeAs = itemNode.getUint16();
            break;
          default:
            // print('skipping $dataLength bytes');
            itemNode.getUint8List(dataLength);
        }
      }

      // print('serverId $serverId clientId $clientId');

      otbItems[clientId] = Item(
          id: serverId,
          name: name,
          stackable: stackable,
          splash: splash,
          fluidContainer: fluidContainer);
    });

    return otbItems;
  }

  static Future<List<Item>> load(ItemsLoaderPayload payload) async {
    Map<int, Item> otbItems = await loadOtbItems(payload.otbFilePath);

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
      bool stackable = false;
      bool splash = false;
      bool fluidContainer = false;

      int byte = dat.getUint8();
      // print('byte ' + byte.toString());
      while (byte != 0xFF) {
        if (byte == 0x05) {
          stackable = true;
        } else if (byte == 0x0C) {
          splash = true;
        } else if (byte == 0x0B) {
          fluidContainer = true;
        } else if ([0x00, 0x09, 0x0A, 0x1A, 0x1D, 0x1E].contains(byte)) {
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
                  img.Image(width * m.TILE_SIZE, height * m.TILE_SIZE);
              for (int layer = 0; layer < layers; layer++) {
                for (int h = 0; h < height; h++) {
                  for (int w = 0; w < width; w++) {
                    int spriteId = dat.getUint16(endian: Endian.little);
                    // print('spriteId $spriteId');
                    Sprite? sprite =
                        (spriteId >= 2 && spriteId <= sprites.length + 2)
                            ? sprites.firstWhere((s) => s.id == spriteId)
                            : null;
                    if (sprite != null) {
                      img.copyInto(
                        texture,
                        img.Image.fromBytes(
                            m.TILE_SIZE, m.TILE_SIZE, sprite.pixels),
                        dstX: (width - w - 1) * m.TILE_SIZE,
                        dstY: (height - h - 1) * m.TILE_SIZE,
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
                bytes: texture.getBytes(),
                bitmap: headed,
              ));
            }
          }
        }
      }

      int id = i + 100;

      // Item? otbItem = otbItems[id];

      // if (otbItem == null) {
      //   print('Item $id not found in otbItems');
      // }

      // if (otbItem!.stackable || otbItem.splash || otbItem.fluidContainer) {
      //   print(
      //       'Item $id, stackable ${otbItem.stackable}, splash ${otbItem.splash}, fluidContainer ${otbItem.fluidContainer}');
      // }

      // if (stackable) {
      //   print('item $id stackable');
      // }

      // if (splash) {
      //   print('item $id splash');
      // }

      // if (fluidContainer) {
      //   print('item $id fluidContainer');
      // }

      Item? otbItem = otbItems[id];

      if (otbItem != null) {
        id = otbItem.id;
      }

      items.add(Item(
        id: id,
        name: '',
        // 'spritesCount $spritesCount, width $width, height $height, layers $layers, patterns x $patterns_x, patterns y $patterns_y, patterns z $patterns_z, frames $frames',
        stackable: stackable,
        splash: splash,
        fluidContainer: fluidContainer,
        textures: textures,
      ));

      progress.itemsProgress = (i + 1) / itemsCount / 2;
      sendPort.send(progress);
    }

    return items;
  }
}
