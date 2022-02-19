import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_painter.dart';
import 'package:otstudio/src/widgets/interactive_canvas.dart';

class MapView extends StatelessWidget {
  late MapPainter painter;
  final Offset offset =
      Offset(32369 * Sprite.SIZE.toDouble(), 32241 * Sprite.SIZE.toDouble());
  final Offset? mouse = null;

  MapView();

  @override
  Widget build(BuildContext context) => BlocBuilder<ProjectBloc, ProjectState>(
          builder: (BuildContext context, state) {
        painter = MapPainter(project: state.project);
        return Container(
            color: Colors.black,
            child: RepaintBoundary(
              child: InteractiveCanvas(
                painter: painter,
                size: Size(state.project.map.map.width.toDouble() * Sprite.SIZE,
                    state.project.map.map.height.toDouble() * Sprite.SIZE),
                offset: offset,
                mouse: mouse ?? Offset.zero,
                selectedItemId: state.project.map.selectedItemId,
              ),
            ));
      });
}
