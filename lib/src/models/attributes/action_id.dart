import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class ActionId extends Attribute<int> {
  int id;

  ActionId(this.id);

  @override
  Attribute fromJson(String json) {
    int id = jsonDecode(json);
    return ActionId(id);
  }

  @override
  int toJson() => id;
}
