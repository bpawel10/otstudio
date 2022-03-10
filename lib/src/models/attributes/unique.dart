import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class Unique extends Attribute<int> {
  int id;

  Unique(this.id);

  @override
  Attribute fromJson(String json) {
    int id = jsonDecode(json);
    return Unique(id);
  }

  @override
  int toJson() => id;
}
