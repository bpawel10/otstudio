import 'dart:ui';

class Position {
  final int x;
  final int y;
  final int z;

  Position(this.x, this.y, this.z);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is Position && other.x == x && other.y == y && other.z == z;
  }

  @override
  int get hashCode => hashValues(x, y, z);
}
