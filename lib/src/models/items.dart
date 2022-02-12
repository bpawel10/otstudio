import 'package:otstudio/src/models/item.dart';

class Items {
  final Map<int, Item> items;

  Items({required this.items});

  int get length => items.length;

  Item getByIndex(int index) => items.values.elementAt(index);
}
