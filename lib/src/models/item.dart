import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import './texture.dart' as t;

class Item {
  final int id;
  final String name;
  final bool stackable;
  final bool splash;
  final bool fluidContainer;
  // final int spriteId;
  // final Uint8List bitmap;
  final List<t.Texture> textures;
  // Image image;
  // final List<Uint8List> sprites; // TEMPORARY
  //final Future<ui.Image> uiImageFuture;
  // ui.Image uiImage;
  // List<Image> images;

  Item({
    required this.id,
    required this.name,
    this.stackable = false,
    this.splash = false,
    this.fluidContainer = false,
    this.textures = const [],
    // this.spriteId,
    // this.bitmap,
    // this.image,
    // this.uiImage,
    // this.sprites,
    // this.images,
  });
}
