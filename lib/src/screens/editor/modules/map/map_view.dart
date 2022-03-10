import 'package:flutter/material.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_canvas.dart';
import 'package:otstudio/src/models/position.dart';

class MapView extends StatelessWidget {
  final Position position;

  MapView({required this.position});

  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.black, child: MapCanvas(position: position));
}
