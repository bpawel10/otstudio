import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/models/tile.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/texture.dart' as modelTexture;
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/models/atlas.dart';

class MapPainter extends CustomPainter {
  final Project project;
  final Offset offset;
  final double scale;
  final Size viewport;
  final Offset mouse;

  MapPainter({
    required this.project,
    this.offset = Offset.zero,
    this.scale = 1,
    required this.viewport,
    this.mouse = Offset.zero,
  });

  static Offset offsetToTileOffset(Offset offset) {
    double dx = Sprite.SIZE * (offset.dx / Sprite.SIZE).floorToDouble();
    double dy = Sprite.SIZE * (offset.dy / Sprite.SIZE).floorToDouble();
    return Offset(dx, dy);
  }

  static Offset positionToTileOffset(Position position) {
    double dx = (position.x * Sprite.SIZE).toDouble();
    double dy = (position.y * Sprite.SIZE).toDouble();
    return Offset(dx, dy);
  }

  static Position offsetToPosition(Offset offset, int floor) => Position(
      (offset.dx / Sprite.SIZE).floor(),
      (offset.dy / Sprite.SIZE).floor(),
      floor);

  static Rect tileRectToPositionRect(Rect tileRect) => Rect.fromLTRB(
      (tileRect.left / Sprite.SIZE).floor().toDouble(),
      (tileRect.top / Sprite.SIZE).floor().toDouble(),
      (tileRect.right / Sprite.SIZE).ceil().toDouble(),
      (tileRect.bottom / Sprite.SIZE).ceil().toDouble());

  void paintItem(Canvas canvas, Paint paint, Offset offset, Item item,
      {double opacity = 1.0}) {
    modelTexture.Texture? texture =
        project.assets.items.items[item.id]?.textures.first;

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
    Stopwatch renderStopwatch = new Stopwatch()..start();

    Rect visiblePositionRect = tileRectToPositionRect(offset &
        (Size(size.width + Sprite.SIZE, size.height + Sprite.SIZE) / scale));

    Rect renderablePositionRect = Rect.fromCenter(
        center: visiblePositionRect.center,
        width: visiblePositionRect.width,
        height: visiblePositionRect.height);

    Paint paint = Paint();
    Map<String, Tile> tiles = project.map.map.tiles;

    for (int x = renderablePositionRect.left.toInt();
        x < renderablePositionRect.right;
        x++) {
      for (int y = renderablePositionRect.top.toInt();
          y < renderablePositionRect.bottom;
          y++) {
        Tile? tile = tiles[Position(x, y, 7).toString()];

        if (tile != null) {
          Offset tileOffset = positionToTileOffset(tile.position);
          tile.items.forEach((Item item) {
            paintItem(
                canvas,
                paint,
                tileOffset - project.assets.items.items[item.id]!.drawOffset,
                item);
            tileOffset =
                tileOffset - project.assets.items.items[item.id]!.heightOffset;
          });
        }
      }
    }

    renderStopwatch.stop();
    print('rendered tiles in ${renderStopwatch.elapsedMilliseconds} ms');
  }

  void paintAtlas(Canvas canvas, Size size, Atlas atlas) {
    Stopwatch renderStopwatch = new Stopwatch()..start();

    Rect visiblePositionRect = tileRectToPositionRect(
        Offset(offset.dx + Sprite.SIZE, offset.dy + Sprite.SIZE) &
            Size(size.width + Sprite.SIZE, size.height + Sprite.SIZE) / scale);

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
        for (int y = renderablePositionRect.top.toInt();
            y < renderablePositionRect.bottom;
            y++) {
          Tile? tile = project.map.map.tiles[Position(x, y, z).toString()];

          if (tile != null) {
            tile.items.forEach((item) {
              Offset tileOffset = positionToTileOffset(tile.position);

              modelTexture.Texture? texture =
                  project.assets.items.items[item.id]?.textures.first;
              ui.Rect? rect = atlas.rects[item.id];

              if (texture != null && rect != null) {
                transforms.add(RSTransform.fromComponents(
                    rotation: 0,
                    scale: 1 / atlas.scale,
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
      atlas.atlas,
      transforms,
      rects,
      [],
      null,
      null,
      paint,
    );

    renderStopwatch.stop();
    print('rendered atlas in ${renderStopwatch.elapsedMilliseconds} ms');
  }

  void paintSelectedItem(Canvas canvas, int selectedItemId, Offset mouse) {
    Item item = project.assets.items.items[selectedItemId]!;
    Offset mouseTileOffset = offsetToTileOffset(mouse);
    // print('mouseTileOffset ${mouseTileOffset}');
    paintItem(canvas, Paint(), mouseTileOffset, item, opacity: 0.5);
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('paint offset $offset scale $scale size $size viewport $viewport');
    print('paint position ${offsetToPosition(offset, 7)}');
    // canvas.drawColor(Colors.red, ui.BlendMode.clear);
    // canvas.drawColor(Colors.red, ui.BlendMode.dst);
    // canvas.drawRect(Offset.zero & Size(100, 100), Paint()..color = Colors.red);

    canvas.translate(-offset.dx, -offset.dy);
    canvas.scale(scale);

    // canvas.clipRect(offset & viewport);
    if (scale > 0.9) {
      paintTiles(canvas, viewport);
    } else if (scale > 0.7) {
      paintAtlas(canvas, viewport, project.assets.items.atlas!);
    } else {
      paintAtlas(canvas, viewport, project.assets.items.atlas2px!);
    }
    // if (project.map.selectedItemId != null) {
    //   paintSelectedItem(canvas, project.map.selectedItemId!, offset + mouse);
    // }
    // paintAtlas(canvas, size, Offset.zero);
  }

  @override
  bool shouldRepaint(MapPainter old) => true;
  // old.offset != offset ||
  // old.scale != scale ||
  // offsetToPosition(old.offset + old.mouse, 0) !=
  //     offsetToPosition(offset + mouse, 0);
}
