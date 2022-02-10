import 'dart:typed_data';

class Sprite {
  static const SIZE = 32;
  static const BYTES = SIZE * SIZE * 4;

  final int id;
  final Uint8List pixels;

  Sprite(this.id, this.pixels);
}
