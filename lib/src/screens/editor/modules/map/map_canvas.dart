import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_painter.dart';

class MapCanvas extends StatefulWidget {
  final Position position;

  MapCanvas({required this.position});

  @override
  _State createState() => _State();
}

class _State extends State<MapCanvas> {
  Offset? offset;
  Position? mousePosition;
  Offset mouse = Offset.zero;
  // MapPainter? painter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (offset == null) {
          offset = MapPainter.positionToTileOffset(widget.position) -
              Offset(constraints.biggest.width / 2,
                  constraints.biggest.height / 2) +
              Offset(Sprite.SIZE / 2, Sprite.SIZE / 2);
        }
        return BlocBuilder<ProjectBloc, ProjectState>(
            builder: (BuildContext context, ProjectState state) => GestureDetector(
                onScaleUpdate: (ScaleUpdateDetails details) {
                  if (state.project.map.selectedItemId == null) {
                    setState(() {
                      offset = offset! - details.focalPointDelta;
                    });
                  } else {
                    // setState(() {
                    mouse += details.focalPointDelta;
                    // });
                    Position newMousePosition = MapPainter.offsetToPosition(
                        offset! + mouse, widget.position.z);
                    if (mousePosition != newMousePosition) {
                      mousePosition = newMousePosition;
                      context.read<ProjectBloc>().add(AddItemToMapProjectEvent(
                          id: state.project.map.selectedItemId!,
                          position: newMousePosition));
                    }
                  }
                },
                // onTap: () => context.read<ProjectBloc>().add(
                //     AddItemToMapProjectEvent(
                //         id: state.project.map.selectedItemId!,
                //         position:
                //             MapPainter.offsetToPosition(offset! + mouse, 7))),
                child: MouseRegion(
                    onHover: (PointerHoverEvent event) => setState(() {
                          mouse = event.localPosition;
                        }),
                    child: CustomPaint(
                        size: constraints.biggest,
                        painter: MapPainter(
                          project: state.project,
                          offset: offset!,
                          mouse: mouse,
                        )))));
      });
}
