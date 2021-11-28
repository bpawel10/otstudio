import 'dart:typed_data';
import 'dart:ui' as ui;

class Texture {
  final int width;
  final int height;
  final Uint8List bitmap;
  ui.Image? image;

  Texture(
      {required this.width,
      required this.height,
      required this.bitmap,
      this.image});
}
