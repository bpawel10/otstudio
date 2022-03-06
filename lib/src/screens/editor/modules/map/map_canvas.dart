import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_painter.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;

class MapCanvas extends StatefulWidget {
  final Position position;

  MapCanvas({required this.position});

  @override
  _State createState() => _State();
}

class _State extends State<MapCanvas> {
  Offset? offset;
  double scale = 1;
  Position? mousePosition;
  Offset mouse = Offset.zero;
  // TransformationController? controller;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        // if (controller == null) {
        if (offset == null) {
          offset = MapPainter.positionToTileOffset(widget.position) -
              Offset(constraints.biggest.width / 2,
                  constraints.biggest.height / 2) +
              Offset(Sprite.SIZE / 2, Sprite.SIZE / 2);
          // controller = TransformationController(
          //     Matrix4.identity()..translate(-offset.dx, -offset.dy));
        }
        return BlocBuilder<ProjectBloc, ProjectState>(
            builder: (BuildContext context, ProjectState state) => Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  if (event is PointerScrollEvent) {
                    // print(
                    //     'scroll delta ${event.scrollDelta} localPosition ${event.localPosition}');
                    print(
                        'event scrollDelta ${event.scrollDelta} localDelta ${event.localDelta} delta ${event.delta}');
                    double newScale = max(
                        min(scale + event.scrollDelta.dy * -0.001, 3), 0.05);
                    print('scale $scale newScale $newScale');
                    Offset mouseGlobalOffset = Offset(
                        offset!.dx + event.localPosition.dx,
                        offset!.dy + event.localPosition.dy);
                    setState(() {
                      Offset newMouseGlobalOffset = mouseGlobalOffset;
                      // Offset change0 = Offset(constraints.biggest.width / 2

                      // Offset almostWorkingChange = Offset(
                      //     event.localPosition.dx * (newScale - scale),
                      //     event.localPosition.dy * (newScale - scale));

                      // Offset almostWorkingChange = Offset(event.localPosition.dx - event.localPosition -

                      // Offset almostWorkingChange = Offset(
                      //     (offset!.dx + event.localPosition.dx) /
                      //         event.localPosition.dx *
                      //         (newScale - scale) /
                      //         newScale,
                      //     event.localPosition.dy *
                      //         (newScale - scale) /
                      //         newScale);
                      // print('almostWorkingChange $almostWorkingChange');
                      // Offset change = Offset(
                      //     event.localPosition.dx -
                      //         event.localPosition.dx * (newScale / scale),
                      //     event.localPosition.dy -
                      //         event.localPosition.dy * (newScale / scale));

                      // Offset newOffset = Offset(
                      //     offset!.dx + change.dx, offset!.dx + change.dy);
                      // print('change $change');
                      // offset = Offset(
                      //     offset!.dx + change.dx, offset!.dy + change.dy);
                      // offset = Offset(offset!.dx + almostWorkingChange.dx,
                      //     offset!.dy + almostWorkingChange.dy);

                      // offset = Offset(
                      //     event.localPosition.dx -
                      //         newScale /
                      //             scale *
                      //             (event.localPosition.dx - offset!.dx),
                      //     event.localPosition.dy -
                      //         newScale /
                      //             scale *
                      //             (event.localPosition.dy - offset!.dy));

                      double localMouseX = event.localPosition.dx;
                      double globalMouseX = offset!.dx + localMouseX / scale;
                      // double newGlobalMouseX =
                      //     newOffsetDx + localMouseX / newScale;

                      // double newOffsetDx =
                      //     offset!.dx + localMouseX / (scale - newScale);

                      double viewDx = constraints.biggest.width / newScale;

                      // offset = Offset(
                      //     offset!.dx -
                      //         event.localPosition.dx *
                      //             (newScale - scale) /
                      //             scale,
                      //     offset!.dy -
                      //         event.localPosition.dy *
                      //             (newScale - scale) /
                      //             scale);

                      // offset = Offset(
                      //     event.localPosition.dx * (newScale - scale),
                      //     event.localPosition.dy * (newScale - scale));

                      // double newOffsetX = offset!.dx +

                      // offset = Offset(
                      //   offset!.dx +
                      //       (event.localPosition.dx -
                      //               constraints.biggest.width / 2) *
                      //           (newScale - scale),
                      //   offset!.dy +
                      //       (event.localPosition.dy -
                      //               constraints.biggest.height / 2) *
                      //           (newScale - scale),
                      // );
                      scale = newScale;
                    });
                  }
                },
                child: GestureDetector(
                    onScaleUpdate: (ScaleUpdateDetails details) {
                      // print('onScaleUpdate');
                      // if (details.scale != scale) {
                      //   double scaleScale = details.scale / scale;
                      //   setState(() {
                      //     offset = details.localFocalPoint -
                      //         details.localFocalPoint
                      //             .translate(-offset!.dx, -offset!.dy)
                      //             .scale(scaleScale, scaleScale);
                      //     scale = details.scale;
                      //   });
                      // }
                      if (state.project.map.selectedItemId == null) {
                        setState(() {
                          offset = offset! - details.focalPointDelta / scale;
                        });
                      } else {
                        mouse += details.focalPointDelta;
                        Position newMousePosition = MapPainter.offsetToPosition(
                            offset! + mouse, widget.position.z);
                        if (mousePosition != newMousePosition) {
                          mousePosition = newMousePosition;
                          context.read<ProjectBloc>().add(
                              AddItemToMapProjectEvent(
                                  id: state.project.map.selectedItemId!,
                                  position: newMousePosition));
                        }
                      }
                    },
                    child: MouseRegion(
                        onHover: (event) => setState(() {
                              mouse = event.localPosition;
                            }),
                        child: CustomPaint(
                            size: Size(
                                (state.project.map.map.width * Sprite.SIZE)
                                    .toDouble(),
                                (state.project.map.map.height * Sprite.SIZE)
                                    .toDouble()), // constraints.biggest,
                            painter: MapPainter(
                              project: state.project,
                              offset: offset! * scale,
                              scale: scale,
                              viewport: constraints.biggest,
                              mouse: mouse,
                            ))))));
      });
}
