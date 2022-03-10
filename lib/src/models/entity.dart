import 'package:otstudio/src/models/attributes/attribute.dart';
import 'attributes/item.dart';

class Entity {
  List<Attribute> attributes;

  Entity({this.attributes = const []});

  Item? item() {
    return attributes.firstWhere(
        (Attribute attribute) => attribute.runtimeType == Item) as Item;
  }

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
