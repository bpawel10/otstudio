import 'package:otstudio/src/models/position.dart';
import 'item.dart';

class Tile {
  final Position position;
  final List<Item> items;

  Tile({required this.position, required this.items});

  Map<String, dynamic> toJson() => {
        position.toString(): {
          'items': items.map((item) => item.toJson()).toList()
        },
      };
}
