import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_painter_old.dart';
import 'package:otstudio/src/models/item.dart';

class InteractiveCanvas extends StatefulWidget {
  final Size size;
  final Offset offset;
  double scale;
  final Offset mouse;
  final MapPainter painter;
  final int? selectedItemId;

  InteractiveCanvas(
      {required this.size,
      this.offset = Offset.zero,
      this.scale = 1, // 0.5, // 1,
      required this.mouse,
      required this.painter,
      this.selectedItemId}) {
    // this.scale = ui.window.devicePixelRatio;
    print('interactive canvas selected item id $selectedItemId');
  }

  @override
  _InteractiveCanvasState createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  late _InteractivePainter painter;
  late Offset mouse;

  @override
  void initState() {
    print('widget.selectedItemId ${widget.selectedItemId}');
    super.initState();
    mouse = widget.mouse;
    painter = _InteractivePainter(
        painter: widget.painter,
        repaint: ValueNotifier(InteractiveCanvasState2(
            offset: widget.offset,
            scale: widget.scale,
            mouse: mouse,
            selectedItemId: widget.selectedItemId)));
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
                  painter.repaint.value.offset -= details.focalPointDelta;
                  // painter.repaint.value.scale = details.scale;
                });
              },
              // onVerticalDragUpdate:(details) {

              // },

              child: MouseRegion(
                  onHover: (event) {
                    if (widget.selectedItemId != null) {
                      setState(() {
                        // print('setState mouse ${event.localPosition}');
                        painter.repaint.value.mouse = event.localPosition;
                      });
                    }
                  },
                  child: CustomPaint(
                      isComplex: true,
                      size: constraints.biggest,
                      painter: painter)));
        })),
        // SizedBox(
        //     height: 50,
        //     child: _InteractiveCanvasStateWidget(
        //         offset: widget.offset, mouse: mouse)),
      ],
    );
  }
}

class _InteractivePainter extends MapPainter {
  // Size size;
  MapPainter painter;
  ValueNotifier<InteractiveCanvasState2> repaint;

  _InteractivePainter({required this.painter, required this.repaint})
      : super(project: painter.project, repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // print('_InteractivePainter.paint');
    // print('size $size');
    Offset offset = repaint.value.offset;
    double scale = repaint.value.scale;
    // print('repaint.value.offset dx ${offset.dx} dy ${offset.dy}');
    // print('repaint.value.scale $scale');
    // print('canvas translate offset dx ${offset.dx} dy ${offset.dy}');
    canvas.translate(-offset.dx * scale, -offset.dy * scale);

    var dpr = ui.window.devicePixelRatio;
    canvas.scale(scale);
    canvas.clipRect(offset & size / scale);
    // print('painter.paint');
    // painter.paintAtlas(canvas, size / scale, offset * scale);
    painter.paintTiles(canvas, size / scale, offset * scale);
    // print('selectedItemId ${repaint.value.selectedItemId} offset $offset mouse ${repaint.value.mouse}');
    if (repaint.value.selectedItemId != null) {
      painter.paintSelectedItem(
          canvas, repaint.value.selectedItemId!, offset + repaint.value.mouse);
    }
    // print('painter painted');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class InteractiveCanvasState2 {
  Offset offset;
  double scale;
  Offset mouse;
  int? selectedItemId;

  InteractiveCanvasState2(
      {required this.offset,
      required this.scale,
      required this.mouse,
      this.selectedItemId});
}

class _InteractiveCanvasStateWidget extends StatelessWidget {
  final Offset offset;
  final Offset mouse;

  _InteractiveCanvasStateWidget({required this.offset, required this.mouse});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Offset: $offset'),
        Text('Mouse: $mouse'),
        Text('Together: ${offset + mouse}')
      ],
    );
  }
}
