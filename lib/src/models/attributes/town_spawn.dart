import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class TownSpawn extends Attribute<int> {
  int id;

  TownSpawn(this.id);

  @override
  Attribute fromJson(String json) {
    int id = jsonDecode(json);
    return TownSpawn(id);
  }

  @override
  int toJson() => id;
}
