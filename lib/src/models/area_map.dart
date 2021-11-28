import 'package:collection/collection.dart';
import './item.dart';
import './position.dart';
import './tile.dart';

class Area {
  String name;
  late List<Area> areas;
  late List<Tile> tiles;

  Area({required this.name, List<Area>? areas, List<Tile>? tiles}) {
    this.areas = areas ?? List.empty(growable: true);
    this.tiles = tiles ?? List.empty(growable: true);
  }

  Tile? getTileByPosition(Position position) {
    print('area($name) getTileByPosition');
    // print('area $name getTileByPosition tiles $tiles');
    // print('position ' +
    //     position.x.toString() +
    //     ', ' +
    //     position.y.toString() +
    //     ', ' +
    //     position.z.toString());
    Tile? tile = tiles.firstWhereOrNull((tile) =>
        tile.position.x == position.x &&
        tile.position.y == position.y &&
        tile.position.z == position.z);
    return tile ??
        areas.fold(
            null, (tile, area) => tile ?? area.getTileByPosition(position));
  }

  List<Tile> getTiles() {
    print('area $name getTiles tiles $tiles');
    return tiles;
  }
}

class AreaMap {
  int width;
  int height;
  late List<Area> areas;

  AreaMap({required this.width, required this.height, this.areas = const []});
  AreaMap.empty({int width = 256, int height = 256})
      : this(width: width, height: height, areas: [Area(name: 'root')]);

  void addItem(Position position, Item item) {
    print('areamap addItem');
    print('areas $areas');
    // print('areass: ' + areas.toString());
    Tile? tile = getTileByPosition(position);
    print('areamap addItem tile $tile');
    if (tile != null) {
      tile.items.add(item);
    } else {
      Area rootArea = areas.firstWhere((area) => area.name == 'root');
      print('rootArea tiles ${rootArea.tiles}');
      rootArea.tiles.add(Tile(position: position, items: [item]));
    }
  }

  Tile? getTileByPosition(Position position) {
    print('areamap.getTileByPosition');
    return areas.fold(
        null, (tile, area) => tile ?? area.getTileByPosition(position));
  }

  List<Tile> getTiles() {
    List<Tile> tiles = [];
    areas.forEach((area) {
      tiles.addAll(area.getTiles());
    });
    return tiles;
  }
}
