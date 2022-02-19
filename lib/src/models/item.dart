import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import './texture.dart' as t;

class Item {
  final int id;
  final String name;
  final Color? minimap;
  final bool ground;
  final bool stackable;
  final bool splash;
  final bool fluidContainer;
  final Offset drawOffset;
  final Offset heightOffset;
  final List<Item> children;
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
    this.minimap,
    this.ground = false,
    this.stackable = false,
    this.splash = false,
    this.fluidContainer = false,
    this.drawOffset = Offset.zero,
    this.heightOffset = Offset.zero,
    this.children = const [],
    this.textures = const [],
    // this.spriteId,
    // this.bitmap,
    // this.image,
    // this.uiImage,
    // this.sprites,
    // this.images,
  });

  // TODO: use entity with attributes instead in map and use item only in items
  dynamic toJson() => children.isEmpty
      ? id
      : {
          'id': id,
          'items': children.map((child) => child.toJson()).toList(),
        };
}
