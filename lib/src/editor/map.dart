import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otstudio/src/editor/cursor_painter.dart';
import '../models/area_map.dart';
import '../models/item.dart';
import '../models/position.dart';
import '../models/tile.dart';
import './map_painter.dart';

const TILE_SIZE = 32;

class Map extends StatefulWidget {
  final AreaMap? map;
  final List<Item> items;
  final int width;
  final int height;
  final Item? selectedItem;

  Map(
      {this.map,
      required this.items,
      required this.width,
      required this.height,
      this.selectedItem});

  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> {
  late AreaMap map;
  late Offset offset;
  late Size size;
  // double zoom = 1;
  // double scale = 1;
  Offset? mouse;
  Position? adding;
  bool repaint = false;
  late TransformationController controller;

  @override
  initState() {
    super.initState();
    map = widget.map ?? AreaMap.empty();
    print('map width ${map.width} height ${map.height}');
    // double tileSize = getTileSize();
    size = Size(widget.width.toDouble() * TILE_SIZE,
        widget.height.toDouble() * TILE_SIZE);
    print('size $size');
    offset = Offset(32369 * TILE_SIZE.toDouble(),
        32241 * TILE_SIZE.toDouble()); // size.width / 2, size.height / 2);
    print('offset $offset');
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => setState(() => repaint = false));
    // offset = Offset(size.width / 2, size.height / 2);
    // print('offset $offset');
    controller = TransformationController(
        Matrix4.identity()..translate(-offset.dx, -offset.dy));
  }

  // double getTileSize() {
  //   return TILE_SIZE * zoom;
  // }

  Position offsetToPosition(Offset offset) {
    // double tileSize = getTileSize();
    // int x = ((this.offset.dx + offset.dx) / TILE_SIZE).floor();
    // int y = ((this.offset.dy + offset.dy) / TILE_SIZE).floor();
    int x = (offset.dx / TILE_SIZE).floor();
    int y = (offset.dy / TILE_SIZE).floor();
    // print('x $x, y $y');
    return Position(x, y, 7); // TODO: handle z;
  }

  addItem(Offset tapOffset) {
    print('addItem, tapOffset $tapOffset');
    if (widget.selectedItem != null) {
      Position tapPosition = offsetToPosition(tapOffset);
      print('addItem, tapPosition ${tapPosition.x} ${tapPosition.y}');
      if (adding == null ||
          (tapPosition.x != adding?.x ||
              tapPosition.y != adding?.y ||
              tapPosition.z != adding?.z)) {
        // print('tapPosition ' +
        //     tapPosition.x.toString() +
        //     ', ' +
        //     tapPosition.y.toString() +
        //     ', ' +
        //     tapPosition.z.toString());
        setState(() {
          adding = tapPosition;
          repaint = true;
        });
        map.addItem(tapPosition, widget.selectedItem!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool repaint = this.repaint;
    print('repaint $repaint');
    return Container(
        color: Colors.black,
        // child: Scrollbar(
        child: InteractiveViewer(
            constrained: false,
            transformationController: controller,
            minScale: 0.01,
            maxScale: 10,
            // onInteractionUpdate: (details) {
            //   // offset = details.focalPoint;
            //   // scale = details.scale;
            //   print(
            //       'delta ${details.focalPointDelta} offset $offset localOffset ${details.localFocalPoint} scale $scale');

            //   // scale = details.scale;
            //   // offset -= details.focalPointDelta / scale;
            // },
            child: GestureDetector(
                onPanDown: (DragDownDetails details) =>
                    addItem(details.localPosition),
                onPanUpdate: (DragUpdateDetails details) =>
                    addItem(details.localPosition),
                onPanEnd: (_) => setState(() => adding = null),
                onPanCancel: () => setState(() => adding = null),
                child: MouseRegion(
                    onEnter: (PointerEnterEvent event) =>
                        setState(() => mouse = event.localPosition),
                    onHover: (PointerHoverEvent event) =>
                        setState(() => mouse = event.localPosition),
                    onExit: (_) => setState(() => mouse = null),
                    child: RepaintBoundary(
                        child: CustomPaint(
                      size: size,
                      painter: MapPainter(
                        map: map,
                        position: offsetToPosition(offset),
                        items: widget.items,
                        // offset: offset,
                        // zoom: zoom,
                        mouse: mouse,
                        selectedItem: widget.selectedItem,
                        // repaint: repaint,
                      ),
                      // foregroundPainter: CursorPainter(
                      //     map: map,
                      //     items: widget.items,
                      //     mouse: mouse,
                      //     selectedItem: widget.selectedItem),
                    ))))));
  }

  // @override
  // Widget build(BuildContext context) => Container(
  //     decoration: BoxDecoration(color: Colors.black),
  //     child: Listener(
  //         onPointerSignal: (PointerSignalEvent event) {
  //           print('signal!');
  //           if (event is PointerScrollEvent) {
  //             print('scroll!');
  //             print('scrolldelta ' + event.scrollDelta.toString());
  //             double newZoom =
  //                 min(max(zoom - event.scrollDelta.dy / 1000, 0.1), 2);
  //             double zoomDiff = newZoom - zoom;
  //             setState(() {
  //               Offset zoomOffset = event.localPosition;
  //               Offset center =
  //                   Offset(context.size.width / 2, context.size.height / 2);
  //               print('zoomOffset ' + zoomOffset.toString());
  //               print('center ' + center.toString());
  //               double dx = (center.dx - zoomOffset.dx) * zoomDiff;
  //               double dy = (center.dy - zoomOffset.dy) * zoomDiff;
  //               print('dx ' + dx.toString() + ', dy ' + dy.toString());
  //               offset = Offset(offset.dx + dx, offset.dy + dy);
  //               // event.localPosition
  //               // Offset zoomPosition = event.localPosition;
  //               // print('newzoom ' + newZoom.toString());
  //               // print('zoomPosition ' + zoomPosition.toString());
  //               // double dx = context.size.width / 2 - zoomPosition.dx;
  //               // double dy = context.size.height / 2 - zoomPosition.dy;
  //               // print('dxx ' + dx.toString());
  //               // print('dyy ' + dy.toString());
  //               // offset = Offset(
  //               //     (offset.dx * zoomDiff) + dx, (offset.dy * zoomDiff) + dy);
  //               zoom = newZoom;
  //             });
  //             print('zoom ' + zoom.toString());
  //           }
  //         },
  //         child: GestureDetector(
  //             onPanDown: (DragDownDetails details) =>
  //                 addItem(details.localPosition),
  //             onPanUpdate: (DragUpdateDetails details) =>
  //                 addItem(details.localPosition),
  //             onPanEnd: (_) => setState(() => adding = null),
  //             onPanCancel: () => setState(() => adding = null),
  //             child: MouseRegion(
  //                 onEnter: (PointerEnterEvent event) =>
  //                     setState(() => mouse = event.localPosition),
  //                 onHover: (PointerHoverEvent event) =>
  //                     setState(() => mouse = event.localPosition),
  //                 onExit: (_) => setState(() => mouse = null),
  //                 child: CustomPaint(
  //                     size: Size.infinite,
  //                     painter: MapPainter(
  //                       map: map,
  //                       offset: offset,
  //                       zoom: zoom,
  //                       mouse: mouse,
  //                       selectedItem: widget.selectedItem,
  //                     ))))));
}
