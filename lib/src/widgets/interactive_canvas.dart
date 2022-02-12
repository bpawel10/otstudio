import 'package:flutter/material.dart';

class InteractiveCanvas extends StatefulWidget {
  final Size size;
  final Offset offset;
  final double scale;
  final Offset mouse;
  final CustomPainter painter;

  InteractiveCanvas(
      {required this.size,
      this.offset = Offset.zero,
      this.scale = 1, // 0.5, // 1,
      required this.mouse,
      required this.painter});

  @override
  _InteractiveCanvasState createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  late _InteractivePainter painter;
  late Offset mouse;

  @override
  void initState() {
    super.initState();
    mouse = widget.mouse;
    painter = _InteractivePainter(
        painter: widget.painter,
        repaint: ValueNotifier(InteractiveCanvasState2(
            offset: widget.offset, scale: widget.scale)));
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: Column(
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
                    // setState(() {
                    mouse = event.localPosition;
                    // });
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
    ));
  }
}

class _InteractivePainter extends CustomPainter {
  // Size size;
  CustomPainter painter;
  ValueNotifier<InteractiveCanvasState2> repaint;

  _InteractivePainter({required this.painter, required this.repaint})
      : super(repaint: repaint);

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
    // canvas.scale(scale);
    canvas.clipRect(offset & size);
    // print('painter.paint');
    painter.paint(canvas, size);
    // print('painter painted');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class InteractiveCanvasState2 {
  Offset offset;
  double scale;

  InteractiveCanvasState2({required this.offset, required this.scale});
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
