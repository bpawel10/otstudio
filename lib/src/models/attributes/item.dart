import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class Item extends Attribute<int> {
  int id;

  Item(this.id);

  @override
  Attribute fromJson(String json) {
    int id = jsonDecode(json);
    return Item(id);
  }

  @override
  int toJson() => id;
}
