import './item.dart';
import './position.dart';
import './tile.dart';

class Area {
  String name;
  List<Area> areas;
  List<Tile> tiles;

  Area({this.name, List<Area> areas, List<Tile> tiles})
      : areas = areas ?? [],
        tiles = tiles ?? [];

  getTileByPosition(Position position) {
    // print('position ' +
    //     position.x.toString() +
    //     ', ' +
    //     position.y.toString() +
    //     ', ' +
    //     position.z.toString());
    Tile tile = tiles.firstWhere(
        (tile) =>
            tile.position.x == position.x &&
            tile.position.y == position.y &&
            tile.position.z == position.z,
        orElse: () => null);
    return tile ??
        areas.fold(
            null, (tile, area) => tile ?? area.getTileByPosition(position));
  }

  getTiles() {
    return tiles;
  }
}

class AreaMap {
  List<Area> areas;

  AreaMap({this.areas = const []});
  AreaMap.empty() {
    areas = [Area(name: 'root')];
  }

  addItem(Position position, Item item) {
    // print('areass: ' + areas.toString());
    Tile tile = getTileByPosition(position);
    if (tile != null) {
      tile.items.add(item);
    } else {
      areas
          .firstWhere((area) => area.name == 'root')
          .tiles
          .add(Tile(position: position, items: [item]));
    }
  }

  getTileByPosition(Position position) {
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
