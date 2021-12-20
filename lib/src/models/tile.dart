import 'package:otstudio/src/models/position.dart';

import './item.dart';

class Tile {
  final Position position;
  // final Item ground;
  final List<Item> items;

  Tile({required this.position, required this.items});

  // set ground(Item ground) {
  //   this.ground = ground;
  // }
}
