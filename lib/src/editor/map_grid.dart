// import 'package:flutter/material.dart';
// import '../models/area_map.dart';
// import '../models/tile.dart';
// import '../models/item.dart';
// import './map_painter.dart';

// class MapGrid extends StatelessWidget {
//   static const GRID_ELEMENT_SIZE = 256.0;

//   final AreaMap map;
//   // late List<Tile> tiles;
//   final List<Item> items;

//   MapGrid({required this.map, required this.items});

//   @override
//   Widget build(BuildContext context) {
//     print('map width ${map.width} height ${map.height}');
//     int gridWidth = (map.width / GRID_ELEMENT_SIZE).ceil();
//     int gridHeight = (map.height / GRID_ELEMENT_SIZE).ceil();

//     print('grid width $gridWidth height $gridHeight');

//     return GridView.builder(
//         padding: EdgeInsets.all(2),
//         itemCount: gridWidth * gridHeight,
//         shrinkWrap: true,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: gridHeight),
//         itemBuilder: (BuildContext context, int index) {
//           Offset gridOffset = Offset((index / gridHeight).floor().toDouble(),
//               (index % gridHeight).toDouble());

//           print('grid item index $index offset $gridOffset');
//           Offset topLeft =
//               gridOffset.scale(GRID_ELEMENT_SIZE, GRID_ELEMENT_SIZE);
//           Offset bottomRight =
//               topLeft.translate(GRID_ELEMENT_SIZE, GRID_ELEMENT_SIZE);
//           Rect rect = Rect.fromPoints(topLeft, bottomRight);
//           List<Tile> tiles = map.getTilesInRect(rect);

//           return CustomPaint(
//               size: Size.square(GRID_ELEMENT_SIZE.toDouble() * TILE_SIZE),
//               painter: MapPainter(
//                 tiles: tiles,
//                 // position: offsetToPosition(offset),
//                 items: items,
//                 // offset: offset,
//                 // zoom: zoom,
//                 // mouse: mouse,
//                 // selectedItem: widget.selectedItem,
//                 // repaint: repaint,
//               ));
//         });
//   }
// }
