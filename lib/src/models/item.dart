import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Item {
  final int id;
  final String name;
  final int spriteId;
  final Uint8List bitmap;
  Image image;
  final List<Uint8List> sprites; // TEMPORARY
  //final Future<ui.Image> uiImageFuture;
  ui.Image uiImage;
  List<Image> images;

  Item(
      {this.id,
      this.name,
      this.spriteId,
      this.bitmap,
      this.image,
      this.uiImage,
      this.sprites,
      this.images});
}
