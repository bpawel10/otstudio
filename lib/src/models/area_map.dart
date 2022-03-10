import 'package:flutter/painting.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'entity.dart';
import 'position.dart';
import 'tile.dart';
import 'attributes/item.dart' as attr;
import 'item.dart';

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

  Size get size => Size(width.toDouble(), height.toDouble());

  void addArea(String name, Area? parent) {
    areas.add(Area(name: name, parent: parent?.name ?? Area.ROOT));
  }

  // void addTileToArea(Area area, Position position, Tile tile) {
  //   areas.firstWhere((a) => a.name == area.name).tiles.add(position);
  // }

  // void removeTileFromArea(Area area, Position position) {
  //   areas.firstWhere((a) => a.name == area.name).tiles.remove(position);
  // }

  void addEntity(Position position, Entity entity) {
    Tile? tile = tiles[position.toString()];
    if (tile != null) {
      tile.entities.add(entity);
      // TODO: handle adding ground where tile already has ground
      // attr.Item? itemAttr = entity.item();
      // if (itemAttr != null) {
      //   Item item = state.project.assets.items.items[itemAttr.id]!;
      //   if (!item.ground || !tile.entities.any((entity) => entity.item()!.id .ground)) {
      //     tile.entities.add(entity);
      //   } else {
      //     tile.items.first = item;
      //   }
      // } else {
      //   tile.entities.add(entity);
      // }
    } else {
      tiles[position.toString()] = Tile(entities: [entity]);
      Area rootArea = areas.firstWhere((area) => area.isRoot);
      rootArea.tiles.add(position);
    }
  }
}
