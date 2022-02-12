import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/models/sprite.dart';

class SprSerializer extends DiskSerializer<SprDocument> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<SprDocument>> tracker) {
    // TODO: implement serialize
    throw UnimplementedError();
  }

  @override
  Future<SprDocument> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) async {
    Uint8List bytes = await File(tracker.data.path).readAsBytes();
    ReadBuffer spr = ReadBuffer(ByteData.view(bytes.buffer));
    int signature = spr.getUint32(endian: Endian.little);
    int spritesCount = spr.getUint16(endian: Endian.little);
    Map<int, Sprite> sprites = Map();
    for (int i = 0; i < spritesCount; i++) {
      int offset = spr.getUint32(endian: Endian.little);
      if (offset != 0) {
        Sprite sprite = _deserializeSprite(bytes, offset, i + 1);
        sprites[sprite.id] = sprite;
        tracker.progress = (i + 1) / spritesCount;
      }
    }
    return SprDocument(signature: signature, sprites: sprites);
  }

  Sprite _deserializeSprite(Uint8List bytes, int offset, int id) {
    ReadBuffer spr =
        ReadBuffer(ByteData.sublistView(bytes.buffer.asUint8List(), offset));
    spr.getUint8();
    spr.getUint8();
    spr.getUint8();
    int coloredBytesCount = spr.getUint16(endian: Endian.little);
    int bytesPut = 0;
    int coloredBytesPut = 0;
    WriteBuffer pixels = WriteBuffer();
    while (coloredBytesPut < coloredBytesCount && bytesPut < Sprite.BYTES) {
      int transparentPixels = spr.getUint16(endian: Endian.little);
      for (int j = 0; j < transparentPixels && bytesPut < Sprite.BYTES; j++) {
        pixels.putUint32(0);
        bytesPut += 4;
      }
      int coloredPixels = spr.getUint16(endian: Endian.little);
      for (int j = 0; j < coloredPixels && bytesPut < Sprite.BYTES; j++) {
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(spr.getUint8());
        pixels.putUint8(0xFF);
        bytesPut += 4;
      }
      coloredBytesPut += 4 + 3 * coloredPixels;
    }
    int bytesPadding = Sprite.BYTES - bytesPut;
    if (bytesPadding > 0) {
      pixels.putUint8List(Uint8List(bytesPadding));
    }
    Uint8List pixelsList = pixels.done().buffer.asUint8List();
    return Sprite(id, pixelsList.sublist(0, Sprite.BYTES));
  }
}

class SprDocument {
  final int signature;
  final Map<int, Sprite> sprites;

  SprDocument({required this.signature, required this.sprites});
}
