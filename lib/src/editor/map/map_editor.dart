import 'package:flutter/material.dart';
import 'package:otstudio/src/editor/map.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/position.dart';

import 'map_painter.dart';
// import 'editor/state.dart' as st;

class MapEditor extends StatefulWidget {
  final AreaMap map;
  late Offset offset;
  final double scale;
  final Offset mouse = Offset.zero;
  final MapPainter painter;

  MapEditor({
    required this.map,
    Position? position,
    this.scale = 1,
    required this.painter,
  }) {
    if (position == null) {
      position = Position((map.width / 2).round(), (map.height / 2).round(), 7);
    }
    this.offset = Offset((position.x * TILE_SIZE).toDouble(),
        (position.y * TILE_SIZE).toDouble());
  }

  @override
  _MapEditorState createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  late Offset mouse;

  @override
  void initState() {
    super.initState();
    mouse = widget.mouse;
    painter = widget.painter;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
              // onPanUpdate: (details) {
              //   setState(() {
              //     painter.repaint.value.offset += details.delta;
              //   });
              // },
              // onVerticalDragUpdate: (details) {
              //   setState(() {
              //     painter.repaint.value.offset -= details.delta;
              //   });
              // },
              // onHorizontalDragUpdate: (details) {
              //   setState(() {
              //     painter.repaint.value.offset -= details.delta;
              //   });
              // },
              onScaleUpdate: (details) {
                // print('scaleUpdate $details');
                setState(() {
                  // painter.repaint.value.offset -= details.focalPointDelta;
                  // painter.repaint.value.scale = details.scale;
                  painter.offset -= details.focalPointDelta;
                });
              },
              // onVerticalDragUpdate:(details) {

              // },

              child: MouseRegion(
                  onHover: (event) {
                    // setState(() {
                    mouse = event.localPosition;
                    // });
                  },
                  child: CustomPaint(
                      size: constraints.biggest, painter: painter)));
        })),
        // SizedBox(
        //     height: 50, child: st.State(offset: widget.offset, mouse: mouse)),
      ],
    );
  }
}

// class _InteractivePainter extends CustomPainter {
//   // Size size;
//   CustomPainter painter;
//   ValueNotifier<InteractiveCanvasState2> repaint;

//   _InteractivePainter({required this.painter, required this.repaint})
//       : super(repaint: repaint);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Offset offset = repaint.value.offset;
//     double scale = repaint.value.scale;
//     canvas.translate(-offset.dx * scale, -offset.dy * scale);
//     canvas.clipRect(offset & size);
//     painter.paint(canvas, size);
//   }

//   @override
//   bool shouldRepaint(MapPainter oldDelegate) =>
//       painter.shouldRepaint(oldDelegate);
// }

// class InteractiveCanvasState2 {
//   Offset offset;
//   double scale;

//   InteractiveCanvasState2({required this.offset, required this.scale});
// }
