import 'entity.dart';

class Tile {
  final List<Entity> entities;

  Tile({required this.entities});

  Map<String, dynamic> toJson() =>
      {'entities': entities.map((item) => item.toJson()).toList()};
}
