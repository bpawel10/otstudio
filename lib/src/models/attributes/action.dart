import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class Action extends Attribute<int> {
  int id;

  Action(this.id);

  @override
  Attribute fromJson(String json) {
    int id = jsonDecode(json);
    return Action(id);
  }

  @override
  int toJson() => id;
}
