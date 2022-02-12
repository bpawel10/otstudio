import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/models/tile.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/texture.dart' as modelTexture;
import 'package:otstudio/src/models/project.dart';

class MapPainter extends CustomPainter {
  final Project project;

  MapPainter({required this.project, Listenable? repaint})
      : super(repaint: repaint);

  Offset positionToTileOffset(Position position) {
    // double tileSize = getTileSize();
    double dx = (position.x * Sprite.SIZE).toDouble(); // - offset.dx;
    double dy = (position.y * Sprite.SIZE).toDouble(); // -offset.dx;
    return Offset(dx, dy);
  }

  Rect tileRectToPositionRect(Rect tileRect) {
    // print('tileRect $tileRect');
    return Rect.fromLTRB(
        (tileRect.left / Sprite.SIZE).floor().toDouble(),
        (tileRect.top / Sprite.SIZE).floor().toDouble(),
        (tileRect.right / Sprite.SIZE).ceil().toDouble(),
        (tileRect.bottom / Sprite.SIZE).ceil().toDouble());
  }

  void paintItem(Canvas canvas, Paint paint, Offset offset, Item item,
      {double opacity = 1.0}) {
    modelTexture.Texture? texture =
        project.assets.items.items[item.id]?.textures[0];

    if (texture != null) {
      Rect rect = texture.rect.translate(offset.dx, offset.dy);
      paintImage(
        canvas: canvas,
        rect: rect,
        image: texture.image!,
        opacity: opacity,
      );
    }
  }

  void paintTiles(Canvas canvas, Size size, ui.Offset offset) {
    Stopwatch renderStopwatch = new Stopwatch()..start();
    // Rect visiblePositionRect = tileRectToPositionRect(
    //     positionToTileOffset(Position(32369, 32241, 7)) & Size(1536.0, 1067.0));
    // Rect renderablePositionRect = Rect.fromCenter(
    //     center: visiblePositionRect.center,
    //     width: visiblePositionRect.width + 20,
    //     height: visiblePositionRect.height + 20);

    Rect visiblePositionRect = tileRectToPositionRect(
        offset & Size(size.width + Sprite.SIZE, size.height + Sprite.SIZE));

    // print('visiblePositionRect $visiblePositionRect');

    // print('visiblePositionRect $visiblePositionRect');
    // print('visiblePositionSize ${visiblePositionRect.size}');

    Rect renderablePositionRect = Rect.fromCenter(
        center: visiblePositionRect.center,
        width: visiblePositionRect.width,
        height: visiblePositionRect.height);

    Paint paint = Paint();
    Map<Position, Tile> tiles = project.map.map.tiles;

    for (int x = renderablePositionRect.left.toInt();
        x < renderablePositionRect.right;
        x++) {
      for (int y = renderablePositionRect.top.toInt();
          y < renderablePositionRect.bottom;
          y++) {
        Tile? tile = tiles[Position(x, y, 7)];

        if (tile != null) {
          Offset tileOffset = positionToTileOffset(tile.position);
          tile.items.forEach((item) {
            paintItem(canvas, paint, tileOffset, item);
          });
        }
      }
    }

    renderStopwatch.stop();
    print('rendered tiles in ${renderStopwatch.elapsedMilliseconds} ms');
  }

  void paintAtlas(Canvas canvas, Size size, ui.Offset offset) {
    Stopwatch renderStopwatch = new Stopwatch()..start();
    // Rect visiblePositionRect = tileRectToPositionRect(
    //     Offset(1035808.0, 1031712.0) & Size(1536.0, 1067.0));

    Rect visiblePositionRect = tileRectToPositionRect(
        Offset(offset.dx + Sprite.SIZE, offset.dy + Sprite.SIZE) &
            Size(size.width + Sprite.SIZE, size.height + Sprite.SIZE));

    // print('visiblePositionRect $visiblePositionRect');

    // print('visiblePositionRect $visiblePositionRect');
    // print('visiblePositionSize ${visiblePositionRect.size}');

    Rect renderablePositionRect = Rect.fromCenter(
        center: visiblePositionRect.center,
        width: visiblePositionRect.width,
        height: visiblePositionRect.height);

    List<RSTransform> transforms = List.empty(growable: true);
    List<Rect> rects = List.empty(growable: true);

    int minZ = 7;

    for (int z = 7; z == 7; z--) {
      for (int x = renderablePositionRect.left.toInt();
          x < renderablePositionRect.right;
          x++) {
        //  int yy = 0;
        for (int y = renderablePositionRect.top.toInt();
            y < renderablePositionRect.bottom;
            y++) {
          // print('x $x y $y');
          Tile? tile = project.map.map.tiles[Position(x, y, z)];

          if (tile != null) {
            tile.items.forEach((item) {
              Offset tileOffset = positionToTileOffset(tile.position);

              // print('atlas rect for item ${item.id} $rect');
              // if (rect != null) {
              modelTexture.Texture? texture =
                  project.assets.items.items[item.id]?.textures[0];
              ui.Rect? rect = project.assets.items.atlas!.rects[item.id];

              if (texture != null && rect != null) {
                // if (x < renderablePositionRect.right + 5 &&
                //     y < renderablePositionRect.bottom + 5) {
                //   print('rect $rect');
                //   print('translateX ${tileOffset.dx - texture.width}');
                //   print('translateY ${tileOffset.dy - texture.height}');
                // }
                transforms.add(RSTransform.fromComponents(
                    rotation: 0,
                    scale: 1,
                    anchorX: 0,
                    anchorY: 0,
                    translateX: (tileOffset.dx -
                            texture.width +
                            (z - minZ) * Sprite.SIZE)
                        .roundToDouble(),
                    translateY: (tileOffset.dy -
                            texture.height +
                            (z - minZ) * Sprite.SIZE)
                        .roundToDouble()));
                rects.add(rect);
                // rects.add(Offset(0, 0) &
                //     Size(texture.width.toDouble(),
                //         texture.height.toDouble())); //rect);
                // }
              }
            });
          }
        }
      }
    }

    Paint paint = Paint();
    // paint.filterQuality = FilterQuality.low;
    // paint.isAntiAlias = false;
    // paint.blendMode = BlendMode.srcIn;

    canvas.drawAtlas(
      project.assets.items.atlas!.atlas,
      transforms,
      rects,
      [],
      null, // BlendMode.srcATop,
      null,
      paint,
    );

    renderStopwatch.stop();
    print('rendered atlas in ${renderStopwatch.elapsedMilliseconds} ms');
  }

  @override
  void paint(Canvas canvas, Size size) {
    // paintTiles(canvas, size);
    paintAtlas(canvas, size, Offset.zero);
  }

  @override
  bool shouldRepaint(MapPainter old) => false;
}
