import 'package:flutter/rendering.dart';
import 'package:otstudio/src/editor/map/map_painter.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/texture.dart' as t;
import 'package:otstudio/src/models/tile.dart';
import '../editor.dart';

class DefaultMapPainter extends MapPainter {
  static const CANVAS_TILE_PADDING = 4;

  DefaultMapPainter(
      {required AreaMap map,
      required Map<int, Item> items,
      required Offset offset,
      required double scale})
      : super(map: map, items: items, offset: offset, scale: scale);

  Rect tileRectToPositionRect(Rect tileRect) {
    return Rect.fromLTRB(
        (tileRect.left / TILE_SIZE).floor().toDouble(),
        (tileRect.top / TILE_SIZE).floor().toDouble(),
        (tileRect.right / TILE_SIZE).ceil().toDouble(),
        (tileRect.bottom / TILE_SIZE).ceil().toDouble());
  }

  Offset positionToTileOffset(Position position) {
    double dx = (position.x * TILE_SIZE).toDouble();
    double dy = (position.y * TILE_SIZE).toDouble();
    return Offset(dx, dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect positionRect = tileRectToPositionRect(super.offset & size);
    Rect renderablePositionRect = Rect.fromCenter(
        center: positionRect.center,
        width: positionRect.width + CANVAS_TILE_PADDING,
        height: positionRect.height + CANVAS_TILE_PADDING);
    for (int x = renderablePositionRect.left.toInt();
        x < renderablePositionRect.right;
        x++) {
      for (int y = renderablePositionRect.top.toInt();
          y < renderablePositionRect.bottom;
          y++) {
        Tile? tile = super.map.tiles[Position(x, y, 7)];
        if (tile != null) {
          Offset tileOffset = positionToTileOffset(tile.position);
          tile.items.forEach((item) {
            t.Texture? texture = super.items[item.id]?.textures[0];
            if (texture != null) {
              Rect rect = texture.rect.translate(tileOffset.dx, tileOffset.dy);
              paintImage(
                canvas: canvas,
                rect: rect,
                scale: super.scale,
                image: texture.image!,
              );
            }
          });
        }
      }
    }
  }

  @override
  bool shouldRepaint(DefaultMapPainter oldDelegate) => false;
}
