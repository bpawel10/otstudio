import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import './item.dart';
import './position.dart';
import './tile.dart';

class Area {
  String name;
  String? parent;
  // late List<Area> areas;
  // late List<Tile> tiles;

  Area({required this.name, this.parent});

  // Area({required this.name, List<Area>? areas, List<Tile>? tiles}) {
  //   this.areas = areas ?? List.empty(growable: true);
  //   this.tiles = tiles ?? List.empty(growable: true);
  // }

  // Tile? getTileByPosition(Position position) {
  //   // print('area($name) getTileByPosition');
  //   // print('area $name getTileByPosition tiles $tiles');
  //   // print('position ' +
  //   //     position.x.toString() +
  //   //     ', ' +
  //   //     position.y.toString() +
  //   //     ', ' +
  //   //     position.z.toString());
  //   Tile? tile = tiles.firstWhereOrNull((tile) =>
  //       tile.position.x == position.x &&
  //       tile.position.y == position.y &&
  //       tile.position.z == position.z);
  //   return tile ??
  //       areas.fold(
  //           null, (tile, area) => tile ?? area.getTileByPosition(position));
  // }

  // List<Tile> getTiles() {
  //   // print('area $name getTiles tiles $tiles');
  //   return tiles;
  // }
}

class AreaMap {
  static const TILEAREA_SIZE = 128;

  int width;
  int height;
  // late List<Area> areas;
  List<Area> areas = List.empty(growable: true);
  Map<Position, Tile> tiles = Map();
  // Map<Offset, Map<Position, Tile>> tileareas = Map();

  AreaMap({required this.width, required this.height});
  AreaMap.empty({int width = 256, int height = 256})
      : this(width: width, height: height);

  void addItem(Position position, Item item) {
    // print('areamap addItem');
    // print('areas $areas');
    // print('areass: ' + areas.toString());
    // Map<Position, Tile> tilearea = getTileareaByPosition(position);
    Tile? tile = tiles[position];
    // print('areamap addItem tile $tile');
    if (tile != null) {
      if (!item.ground || !tile.items.any((item) => item.ground)) {
        tile.items.add(item);
      }
    } else {
      tiles[position] = Tile(position: position, items: [item]);
      // tilearea[position] = Tile(position: position, items: [item]);
      // Area rootArea = areas.firstWhere((area) => area.name == 'root');
      // // print('rootArea tiles ${rootArea.tiles}');
      // rootArea.tiles.add(Tile(position: position, items: [item]));
    }
  }

  // Map<Position, Tile> getTileareaByPosition(Position position) {
  //   Offset tileareaOffset = Offset((position.x / TILEAREA_SIZE).floorToDouble(),
  //       (position.y / TILEAREA_SIZE).floorToDouble());

  //   Map<Position, Tile>? tilearea = tileareas[tileareaOffset];

  //   if (tilearea == null) {
  //     tilearea = Map();
  //     tileareas[tileareaOffset] = tilearea;
  //   }

  //   return tilearea;
  // }

  Tile? getTileByPosition(Position position) {
    // print('areamap.getTileByPosition');
    // return areas.fold(
    //     null, (tile, area) => tile ?? area.getTileByPosition(position));
    // Map<Position, Tile> tilearea = getTileareaByPosition(position);
    // return tilearea[position];
    return tiles[position];
  }

  // void getVisibleTilesForPosition(Position position) {
  //   print(
  //       'getVisibleTilesForPosition ${position.x} ${position.y} ${position.z}');

  //   tileareas.removeWhere((key, value) =>
  //       key.z != position.z ||
  //       (key.x - position.x).abs() > 300 ||
  //       (key.y - position.y).abs() > 300);
  // }

  // List<Tile> getTileareasTilesInRect(Rect rect) {
  //   List<Tile> tiles = tileareas.entries
  //       .where((MapEntry<Offset, Map<Position, Tile>> entry) => rect.contains(
  //           Offset(entry.key.dx * TILEAREA_SIZE, entry.key.dy * TILEAREA_SIZE)))
  //       .map((MapEntry<Offset, Map<Position, Tile>> entry) =>
  //           entry.value.values.toList())
  //       .reduce((List<Tile> tiles, List<Tile> entryTiles) {
  //     tiles.addAll(entryTiles); // .where((tile) => tile.position.z == 7));
  //     return tiles;
  //   });

  //   return tiles;

  // return tiles.values
  //     .where((Tile tile) =>
  //         rect.contains(Offset(
  //             tile.position.x.toDouble(), tile.position.y.toDouble())) &&
  //         tile.position.z == 7)
  //     .toList();
  // }

  // List<Tile> getTiles() {
  //   List<Tile> tiles = [];
  //   areas.forEach((area) {
  //     tiles.addAll(area.getTiles());
  //   });
  //   return tiles;
  // }
}
