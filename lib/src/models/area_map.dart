import 'item.dart';
import 'position.dart';
import 'tile.dart';

class Area {
  static const ROOT = 'root';

  String name;
  String? parent;
  List<Position> tiles = [];

  Area({required this.name, this.parent});

  bool get isRoot => name == ROOT;
}

class RootArea extends Area {
  RootArea() : super(name: Area.ROOT);
}

class AreaMap {
  int width;
  int height;
  List<Area> areas = [RootArea()];
  Map<String, Tile> tiles = Map();

  AreaMap({required this.width, required this.height});
  AreaMap.empty({int width = 256, int height = 256})
      : this(width: width, height: height);

  void addArea(String name, Area? parent) {
    areas.add(Area(name: name, parent: parent?.name ?? Area.ROOT));
  }

  void addTileToArea(Area area, Tile tile) {
    areas.firstWhere((a) => a.name == area.name).tiles.add(tile.position);
  }

  void removeTileFromArea(Area area, Tile tile) {
    areas.firstWhere((a) => a.name == area.name).tiles.remove(tile.position);
  }

  void addItem(Position position, Item item) {
    Tile? tile = tiles[position.toString()];
    if (tile != null) {
      if (!item.ground || !tile.items.any((item) => item.ground)) {
        tile.items.add(item);
      } else {
        tile.items.first = item;
      }
    } else {
      tiles[position.toString()] = Tile(position: position, items: [item]);
      Area rootArea = areas.firstWhere((area) => area.isRoot);
      rootArea.tiles.add(position);
    }
  }
}
