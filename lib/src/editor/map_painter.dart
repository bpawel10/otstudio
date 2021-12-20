import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/area_map.dart';
import './map.dart';
import '../models/item.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'dart:ui' as ui;
import 'package:bitmap/bitmap.dart';
import '../loaders/items_loader.dart';
import '../models/texture.dart' as t;
import 'package:image/image.dart' as img;
import 'package:bitmap/bitmap.dart';
import '../models/atlas.dart';

const TILE_SIZE = 32;

class MapPainter extends CustomPainter {
  // final AreaMap map;
  final List<Tile> tiles;
  final List<Item> items;
  final Atlas atlas;
  Rect visible;
  // final Position position;
  // final Offset offset;
  // final double zoom;
  final Offset? mouse;
  final Item? selectedItem;
  final bool repaint = true;

  MapPainter({
    // required this.map,
    required this.tiles,
    required this.items,
    required this.atlas,
    required this.visible,
    // required this.position,
    this.mouse,
    this.selectedItem,
  });

  // double getTileSize() {
  //   return TILE_SIZE * zoom;
  // }

  Offset offsetToTileOffset(Offset offset) {
    // double tileSize = getTileSize();
    double dx = TILE_SIZE * (offset.dx / TILE_SIZE).floorToDouble();
    double dy = TILE_SIZE * (offset.dy / TILE_SIZE).floorToDouble();
    // print('offset $offset to tileOffset ${Offset(dx, dy)}');
    return Offset(dx, dy);
  }

  Position tileOffsetToPosition(Offset offset) {
    // double tileSize = getTileSize();
    int x = (offset.dx / TILE_SIZE).floor();
    int y = (offset.dy / TILE_SIZE).floor();
    return Position(x, y, 7); // TODO: handle z position
  }

  Offset positionToTileOffset(Position position) {
    // double tileSize = getTileSize();
    double dx = (position.x * TILE_SIZE).toDouble(); // - offset.dx;
    double dy = (position.y * TILE_SIZE).toDouble(); // -offset.dx;
    return Offset(dx, dy);
  }

  Rect tileRectToPositionRect(Rect tileRect) {
    // print('tileRect $tileRect');
    return Rect.fromLTRB(
        (tileRect.left / TILE_SIZE).floor().toDouble(),
        (tileRect.top / TILE_SIZE).floor().toDouble(),
        (tileRect.right / TILE_SIZE).ceil().toDouble(),
        (tileRect.bottom / TILE_SIZE).ceil().toDouble());
  }

  // List<Tile> getVisibleTiles(Size size) {
  //   // double tileSize = getTileSize();
  //   // Offset startTileOffset = offsetToTileOffset(offset);
  //   Position startPosition =
  //       Position(0, 0, 7); // tileOffsetToPosition(startTileOffset);
  //   Position endPosition = Position(256, 256, 8);
  //   print('endPosition ${endPosition.x} ${endPosition.y}');
  //   // Position endPosition = Position(
  //   //     startPosition.x + (size.width / TILE_SIZE).ceil(),
  //   //     startPosition.y + (size.height / TILE_SIZE).ceil(),
  //   //     startPosition.z + 1);

  //   // print('startPosition ' +
  //   //     startPosition.x.toString() +
  //   //     ', ' +
  //   //     startPosition.y.toString() +
  //   //     ', ' +
  //   //     startPosition.z.toString());

  //   // print('endPosition ' +
  //   //     endPosition.x.toString() +
  //   //     ', ' +
  //   //     endPosition.y.toString() +
  //   //     ', ' +
  //   //     endPosition.z.toString());

  //   List<Tile> tiles = [];

  //   for (int x = startPosition.x; x < endPosition.x; x++) {
  //     for (int y = startPosition.y; y < endPosition.y; y++) {
  //       for (int z = startPosition.z; z < endPosition.z; z++) {
  //         for (Area area in map.areas) {
  //           Tile tile = area.getTileByPosition(Position(x, y, z));
  //           // print('visible tile ' + tile.toString());
  //           if (tile != null) {
  //             tiles.add(tile);
  //           }
  //         }
  //       }
  //     }
  //   }

  //   print('tiles length ${tiles.length}');

  //   return tiles;
  // }

  paintItem(Canvas canvas, Offset offset, Item item, {double opacity = 1.0}) {
    // double tileSize = getTileSize();
    t.Texture texture = items.firstWhere((i) => i.id == item.id).textures[0];
    paintImage(
      canvas: canvas,
      rect: offset.translate(-(texture.width.toDouble() - TILE_SIZE),
              -(texture.height.toDouble() - TILE_SIZE)) &
          Size(texture.width.toDouble(), texture.height.toDouble()),
      // scale: 10, // texture.width.toDouble() / TILE_SIZE,
      image: texture.image!, // item.textures[0].image!,
      // fit: BoxFit.none,
      // filterQuality: FilterQuality.high,
      opacity: opacity,
    );
  }

  paintTiles(Canvas canvas, Size size) async {
    // List<Tile> visibleTiles = map.tiles.values.toList();
    // print('visibleTiles.length ${visibleTiles.length}');

    // paintImage(
    //   canvas: canvas,
    //   rect: positionToTileOffset(Position(1040, 1040, 7)) &
    //       Size(atlas.atlas.width.toDouble(), atlas.atlas.height.toDouble()),
    //   // scale: 10, // texture.width.toDouble() / TILE_SIZE,
    //   image: atlas.atlas, // item.textures[0].image!,
    //   // fit: BoxFit.none,
    //   // filterQuality: FilterQuality.high,
    //   opacity: 1,
    // );

    // List<RSTransform> transforms = List.empty(growable: true);
    // List<Rect> rects = List.empty(growable: true);

    // tiles.where((tile) => tile.position.z == 7).forEach((tile) {
    //   Offset tileOffset = positionToTileOffset(tile.position);

    //   tile.items.forEach((item) {
    //     // ui.Rect? rect = atlas.rects[item.id];
    //     // print('atlas rect for item ${item.id} $rect');
    //     // if (rect != null) {
    //     transforms.add(RSTransform.fromComponents(
    //         rotation: 0,
    //         scale: 1,
    //         anchorX: 0,
    //         anchorY: 0,
    //         translateX: tileOffset.dx,
    //         translateY: tileOffset.dy));
    //     rects.add(Offset(0, 0) & Size(32, 32)); //rect);
    //     // }
    //   });
    // });

    // canvas.drawAtlas(
    //   atlas.atlas,
    //   transforms,
    //   rects,
    //   [],
    //   BlendMode.src,
    //   null,
    //   Paint(),
    // );

    Rect visiblePositionRect = tileRectToPositionRect(visible);

    // print('visiblePositionRect $visiblePositionRect');

    tiles
        .where((tile) =>
            visiblePositionRect.contains(Offset(
                tile.position.x.toDouble(), tile.position.y.toDouble())) &&
            tile.position.z == 7)
        .forEach((tile) {
      Offset tileOffset = positionToTileOffset(tile.position);
      // print(
      // 'tile ${tile.position.x} ${tile.position.y} ${tile.position.z} items ${tile.items.length}');
      tile.items.forEach((item) {
        // print(
        //     'position ${tile.position.x} ${tile.position.y} ${tile.position.z} item ${item.id}');
        paintItem(canvas, tileOffset, item);
      });
    });
  }

  @override
  void paint(Canvas canvas, Size size) async {
    // print('MapPainter.paint');
    await paintTiles(canvas, size);
    if (mouse != null && selectedItem != null) {
      Offset mouseTileOffset = offsetToTileOffset(mouse!);
      paintItem(canvas, mouseTileOffset, selectedItem!, opacity: 0.5);
    }
    // print('MapPainter.painted');
  }

  @override
  bool shouldRepaint(MapPainter old) {
    // print('old mouse dx ${old.mouse?.dx} new mouse dx ${mouse?.dx}');

    bool shouldRepaint = false;
    //  old.mouse != mouse || old.map.tiles.length != map.tiles.length; // true;
    // print('MapPainter.shouldRepaint $shouldRepaint');
    return shouldRepaint;
    // return false; // this.repaint;
  }
}
