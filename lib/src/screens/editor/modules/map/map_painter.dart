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

  MapPainter({required this.project});

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

  void paintTiles(Canvas canvas, Size size) {
    Rect visiblePositionRect = tileRectToPositionRect(
        positionToTileOffset(Position(32369, 32241, 7)) & Size(1536.0, 1067.0));
    Rect renderablePositionRect = Rect.fromCenter(
        center: visiblePositionRect.center,
        width: visiblePositionRect.width + 100,
        height: visiblePositionRect.height + 100);

    Paint paint = Paint();

    for (int x = renderablePositionRect.left.toInt();
        x < renderablePositionRect.right;
        x++) {
      for (int y = renderablePositionRect.top.toInt();
          y < renderablePositionRect.bottom;
          y++) {
        Tile? tile = project.map.map.tiles[Position(x, y, 7)];

        if (tile != null) {
          Offset tileOffset = positionToTileOffset(tile.position);
          tile.items.forEach((item) {
            paintItem(canvas, paint, tileOffset, item);
          });
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Stopwatch renderStopwatch = new Stopwatch()..start();
    paintTiles(canvas, size);
    renderStopwatch.stop();
    print('rendered tiles in ${renderStopwatch.elapsedMilliseconds} ms');
  }

  @override
  bool shouldRepaint(MapPainter old) => false;
}
