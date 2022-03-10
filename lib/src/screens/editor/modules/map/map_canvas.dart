import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_painter.dart';
import 'package:vector_math/vector_math_64.dart' show Quad;

class MapCanvas extends StatefulWidget {
  final Position position;

  MapCanvas({required this.position});

  @override
  _State createState() => _State();
}

class _State extends State<MapCanvas> {
  TransformationController? controller;
  Offset mouse = Offset.zero;
  Position? mousePosition;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (controller == null) {
          Offset translation =
              MapPainter.positionToTileOffset(widget.position) -
                  Offset(constraints.biggest.width / 2,
                      constraints.biggest.height / 2) +
                  Offset(Sprite.SIZE / 2, Sprite.SIZE / 2);
          controller = TransformationController(
              Matrix4.identity()..translate(-translation.dx, -translation.dy));
        }
        return BlocBuilder<ProjectBloc, ProjectState>(
            builder: (BuildContext context, ProjectState state) => Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  if (event is PointerScrollEvent) {
                    if (event.scrollDelta.dy == 0.0) {
                      return;
                    }

                    final double scaleChange = exp(-event.scrollDelta.dy / 200);
                    final double currentScale =
                        controller!.value.getMaxScaleOnAxis();
                    final double totalScale = currentScale * scaleChange;
                    final double clampedTotalScale = totalScale.clamp(0.05, 3);
                    final double clampedScale =
                        clampedTotalScale / currentScale;
                    final Offset focalPointScene = controller!.toScene(
                      event.localPosition,
                    );

                    setState(() {
                      controller!.value = controller!.value.clone()
                        ..scale(clampedScale);
                      final Offset focalPointSceneScaled =
                          controller!.toScene(event.localPosition);
                      final Offset translation =
                          focalPointSceneScaled - focalPointScene;
                      controller!.value = controller!.value.clone()
                        ..translate(translation.dx, translation.dy);
                    });
                  }
                },
                onPointerHover: (PointerHoverEvent event) {
                  setState(() {
                    mouse = event.localPosition;
                  });
                },
                child: GestureDetector(
                    onScaleUpdate: (ScaleUpdateDetails details) {
                      final double scale =
                          controller!.value.getMaxScaleOnAxis();
                      setState(() {
                        controller!.value.translate(
                            details.focalPointDelta.dx / scale,
                            details.focalPointDelta.dy / scale);
                      });
                    },
                    child: CustomPaint(
                        size: constraints.biggest,
                        painter: MapPainter(
                          project: state.project,
                          transformation: controller!.value,
                          mouse: mouse,
                        )))));
      });
}
