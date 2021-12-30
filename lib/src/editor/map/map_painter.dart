import 'package:flutter/material.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/item.dart';

abstract class MapPainter extends CustomPainter {
  final AreaMap map;
  final Map<int, Item> items;
  final Offset offset;
  final double scale;

  MapPainter(
      {required this.map,
      required this.items,
      required this.offset,
      required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(-offset.dx, -offset.dy);
    canvas.clipRect(offset & size);
  }
}
