import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:otstudio/src/models/sprite.dart';

class Texture {
  final double width;
  final double height;
  late ui.Size size;
  late ui.Rect rect;
  final Uint8List bytes;
  final Uint8List bitmap;
  ui.Image? image;

  Texture(
      {required this.width,
      required this.height,
      required this.bytes,
      required this.bitmap,
      this.image}) {
    size = ui.Size(width, height);
    rect = ui.Offset(-(width - Sprite.SIZE), -(height - Sprite.SIZE)) & size;
  }
}
