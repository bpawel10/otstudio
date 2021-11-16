import 'package:otstudio/src/models/position.dart';

import './item.dart';

class Tile {
  final Position position;
  final List<Item> items;

  Tile({this.position, this.items});
}
