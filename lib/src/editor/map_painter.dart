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
  final AreaMap map;
  // final List<Tile> tiles;
  final Map<int, Item> items;
  final Atlas atlas;
  Rect visible;
  double scale;
  // final Position position;
  // final Offset offset;
  // final double zoom;
  final Offset? mouse;
  final Item? selectedItem;
  final bool repaint = true;

  MapPainter({
    required this.map,
    // required this.tiles,
    required this.items,
    required this.atlas,
    required this.visible,
    required this.scale,
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

  Offset tileOffsetToCanvasOffset(Offset tileOffset) {
    double dx = tileOffset.dx - visible.left;
    double dy = tileOffset.dy - visible.top;
    return Offset(dx, dy);
  }

  Offset positionToCanvasOffset(Position position) {
    return Offset(position.x * TILE_SIZE - visible.left,
        position.y * TILE_SIZE - visible.top);
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

  paintItem(Canvas canvas, Paint paint, Offset offset, Item item,
      {double opacity = 1.0}) {
    // double tileSize = getTileSize();
    // t.Texture texture = item
    //     .textures[0]; // items.firstWhere((i) => i.id == item.id).textures[0];
    t.Texture? texture = items[item.id]?.textures[0];

    if (texture != null) {
      // Stopwatch rectStopwatch = new Stopwatch()..start();
      // Rect rect = offset.translate(
      //         -(texture.width - TILE_SIZE), -(texture.height - TILE_SIZE)) &
      //     texture.size;
      Rect rect = texture.rect.translate(offset.dx, offset.dy);
      // rectStopwatch.stop();
      // print('rect calculated in ${rectStopwatch.elapsedMicroseconds} micro s');
      // Stopwatch paintStopwatch = new Stopwatch()..start();

      // if (scale >= 0.5) {
      paintImage(
        canvas: canvas,
        rect: rect,
        // scale: 10, // texture.width.toDouble() / TILE_SIZE,
        image: texture.image!, // item.textures[0].image!,
        // fit: BoxFit.none,
        // filterQuality: FilterQuality.high,
        opacity: opacity,
      );
      // } else {
      //   Color? minimap = items[item.id]?.minimap;
      //   if (minimap != null) {
      //     Paint minimapPaint = Paint();
      //     minimapPaint.color = minimap;
      //     // print('painter minimapColor $minimap');
      //     canvas.drawRect(
      //       rect,
      //       minimapPaint,
      //     );
      //   }
      // }
      // Offset offset2 = offset.translate(
      //     -(texture.width - TILE_SIZE), -(texture.height - TILE_SIZE));
      // canvas.drawImage(texture.image!, offset2, paint);

      // paintStopwatch.stop();
      // print('painted in ${paintStopwatch.elapsedMicroseconds} micro s');
    }
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

    Rect visiblePositionRect = tileRectToPositionRect(
        Offset(1035808.0, 1031712.0) & Size(1536.0, 1067.0));

    // print('visiblePositionRect $visiblePositionRect');
    // print('visiblePositionSize ${visiblePositionRect.size}');

    Rect renderablePositionRect = Rect.fromCenter(
        center: visiblePositionRect.center,
        width: visiblePositionRect.width + 100,
        height: visiblePositionRect.height + 100);

    // print('renderablePositionRect $renderablePositionRect');
    // print('renderablePositionSize ${renderablePositionRect.size}');

    // Stopwatch getTilesStopwatch = new Stopwatch()..start();
    // List<Tile> visibleTiles = map.tiles.values
    //     .where((tile) =>
    //         visiblePositionRect.contains(Offset(
    //             tile.position.x.toDouble(), tile.position.y.toDouble())) &&
    //         tile.position.z == 7)
    //     .toList(); //getTileareasTilesInRect(visiblePositionRect);
    // getTilesStopwatch.stop();
    // print('got tiles in ${getTilesStopwatch.elapsedMilliseconds} ms');

    Paint paint = Paint();

    Stopwatch renderStopwatch = new Stopwatch()..start();

    // int xx = 0;

    List<RSTransform> transforms = List.empty(growable: true);
    List<Rect> rects = List.empty(growable: true);

    for (int x = renderablePositionRect.left.toInt();
        x < renderablePositionRect.right;
        x++) {
      //  int yy = 0;
      for (int y = renderablePositionRect.top.toInt();
          y < renderablePositionRect.bottom;
          y++) {
        // print('x $x y $y');
        Tile? tile = map.tiles[Position(x, y, 7)];

        // print('tile $tile');
        if (tile != null) {
          // tiles.where((tile) => tile.position.z == 7).forEach((tile) {
          // Offset tileOffset = positionToTileOffset(tile.position);

          // tile.items.forEach((item) {
          //   // ui.Rect? rect = atlas.rects[item.id];
          //   // print('atlas rect for item ${item.id} $rect');
          //   // if (rect != null) {
          //   t.Texture? texture = items[item.id]?.textures[0];
          //   ui.Rect? rect = atlas.rects[item.id];

          //   if (texture != null && rect != null) {
          //     // if (x < renderablePositionRect.right + 5 &&
          //     //     y < renderablePositionRect.bottom + 5) {
          //     //   print('rect $rect');
          //     //   print('translateX ${tileOffset.dx - texture.width}');
          //     //   print('translateY ${tileOffset.dy - texture.height}');
          //     // }
          //     transforms.add(RSTransform.fromComponents(
          //         rotation: 0,
          //         scale: 1,
          //         anchorX: 0,
          //         anchorY: 0,
          //         translateX: tileOffset.dx - texture.width,
          //         translateY: tileOffset.dy - texture.height));
          //     rects.add(rect);
          //     // rects.add(Offset(0, 0) &
          //     //     Size(texture.width.toDouble(),
          //     //         texture.height.toDouble())); //rect);
          //     // }
          //   }
          // });

          Offset tileOffset = positionToTileOffset(tile.position);
          // // print('render tileOffset $tileOffset');
          // // Offset canvasOffset = positionToCanvasOffset(tile.position);
          // // offsetStopwatch.stop();
          // // print(
          // //     'offsets calculated in ${offsetStopwatch.elapsedMicroseconds} micro s');
          // // print('canvasOffset $canvasOffset');
          // // print(
          // // 'tile ${tile.position.x} ${tile.position.y} ${tile.position.z} items ${tile.items.length}');
          tile.items.forEach((item) {
            // print(
            //     'position ${tile.position.x} ${tile.position.y} ${tile.position.z} item ${item.id}');
            paintItem(canvas, paint, tileOffset, item);
          });
        }

        // yy++;
      }
      // xx++;
    }

    // Paint.enableDithering = true;

    // Paint paint = Paint();
    // paint.filterQuality = FilterQuality.high;
    // // paint.isAntiAlias = false;
    // // paint.blendMode = BlendMode.srcIn;

    // canvas.drawAtlas(
    //   atlas.atlas,
    //   transforms,
    //   rects,
    //   [],
    //   null, // BlendMode.srcATop,
    //   null,
    //   paint,
    // );

    // print('painter map.tiles length ${map.tiles.entries.length}');

    // print('hashCode1 ${Position(1, 1, 7).hashCode}');
    // print('hashCode2 ${Position(1, 1, 7).hashCode}');
    // print('hashCode3 ${Position(1, 1, 7).hashCode}');
    // print('hashCode4 ${Position(1, 1, 7).hashCode}');
    // print('hashCode5 ${Position(1, 1, 7).hashCode}');

    renderStopwatch.stop();
    print('rendered tiles in ${renderStopwatch.elapsedMilliseconds} ms');

    // Stopwatch renderStopwatch = new Stopwatch()..start();
    // visibleTiles
    //     // .where((tile) => tile.position.z == 7)
    //     // .where((tile) =>
    //     //     visiblePositionRect.contains(Offset(
    //     //         tile.position.x.toDouble(), tile.position.y.toDouble())) &&
    //     //     tile.position.z == 7)
    //     .forEach((tile) {
    //   // Stopwatch offsetStopwatch = new Stopwatch()..start();
    //   // Offset tileOffset = positionToTileOffset(tile.position);
    //   // Offset canvasOffset = tileOffsetToCanvasOffset(tileOffset);
    //   Offset canvasOffset = positionToCanvasOffset(tile.position);
    //   // offsetStopwatch.stop();
    //   // print(
    //   //     'offsets calculated in ${offsetStopwatch.elapsedMicroseconds} micro s');
    //   // print('canvasOffset $canvasOffset');
    //   // print(
    //   // 'tile ${tile.position.x} ${tile.position.y} ${tile.position.z} items ${tile.items.length}');
    //   tile.items.forEach((item) {
    //     // print(
    //     //     'position ${tile.position.x} ${tile.position.y} ${tile.position.z} item ${item.id}');
    //     paintItem(canvas, paint, canvasOffset, item);
    //   });
    // });
    // renderStopwatch.stop();
    // print('rendered tiles in ${renderStopwatch.elapsedMilliseconds} ms');
  }

  @override
  void paint(Canvas canvas, Size size) async {
    // canvas.drawColor(Colors.red, BlendMode.color);
    // print('MapPainter.paint');
    await paintTiles(canvas, size);
    if (mouse != null && selectedItem != null) {
      Offset mouseTileOffset = offsetToTileOffset(mouse!);
      paintItem(canvas, Paint(), mouseTileOffset, selectedItem!, opacity: 0.5);
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
