import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/atlas.dart';

class Items {
  final Map<int, Item> items;
  final Atlas? atlas;

  Items({required this.items, this.atlas});

  int get length => items.length;

  Item getByIndex(int index) => items.values.elementAt(index);
}
