import 'package:otstudio/src/models/attributes/attribute.dart';

class Entity {
  List<Attribute> attributes;

  Entity({this.attributes = const []});

  Entity fromJson(String json) {
    // TODO: implement it
    return Entity();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> attributesMap = Map();
    attributes.forEach((attribute) {
      attributesMap.addAll(attribute.toMap());
    });
    return attributesMap;
  }
}
