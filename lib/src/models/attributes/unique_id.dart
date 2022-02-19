import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class UniqueId extends Attribute<int> {
  int id;

  UniqueId(this.id);

  @override
  Attribute fromJson(String json) {
    int id = jsonDecode(json);
    return UniqueId(id);
  }

  @override
  int toJson() => id;
}
