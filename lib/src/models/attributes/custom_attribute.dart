import 'dart:convert';
import 'package:otstudio/src/models/attributes/attribute.dart';

class CustomAttribute extends Attribute<dynamic> {
  List<dynamic> properties = [];

  CustomAttribute({required this.properties});

  @override
  Attribute fromJson(String json) {
    dynamic properties = jsonDecode(json);
    if (properties is List) {
      return CustomAttribute(properties: properties);
    } else {
      return CustomAttribute(properties: []..add(properties));
    }
  }

  @override
  dynamic toJson() => properties;
}
