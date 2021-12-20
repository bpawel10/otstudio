import 'package:flutter/material.dart';
import '../models/area_map.dart';
import './map.dart';
import '../models/item.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'dart:ui' as ui;
import 'package:bitmap/bitmap.dart';
import '../loaders/items_loader.dart';
import '../models/texture.dart' as t;

const TILE_SIZE = 32;

class MapPainter extends CustomPainter {
  final AreaMap map;
  final List<Item> items;
  final Position position;
  // final Offset offset;
  // final double zoom;
  final Offset? mouse;
  final Item? selectedItem;
  final bool repaint = true;

  MapPainter({
    required this.map,
    required this.items,
    required this.position,
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

  paintTiles(Canvas canvas, Size size) {
    // List<Tile> visibleTiles = map.tiles.values.toList();
    // print('visibleTiles.length ${visibleTiles.length}');

    map.tiles.values.forEach((tile) {
      Offset tileOffset = positionToTileOffset(tile.position);
      // print(
      // 'tile ${tile.position.x} ${tile.position.y} ${tile.position.z} items ${tile.items.length}');
      tile.items.forEach((item) {
        print(
            'position ${tile.position.x} ${tile.position.y} ${tile.position.z} item ${item.id}');
        paintItem(canvas, tileOffset, item);
      });
    });
  }

  @override
  void paint(Canvas canvas, Size size) async {
    print('MapPainter.paint');
    paintTiles(canvas, size);
    if (mouse != null && selectedItem != null) {
      Offset mouseTileOffset = offsetToTileOffset(mouse!);
      paintItem(canvas, mouseTileOffset, selectedItem!, opacity: 0.5);
    }
  }

  @override
  bool shouldRepaint(MapPainter old) {
    bool shouldRepaint = true;
    //  old.mouse != mouse || old.map.tiles.length != map.tiles.length; // true;
    print('MapPainter.shouldRepaint $shouldRepaint');
    return shouldRepaint;
    // return false; // this.repaint;
  }
}
