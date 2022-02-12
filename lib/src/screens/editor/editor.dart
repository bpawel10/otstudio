import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/grid/grid.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/grid/tree.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_items.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_module.dart';
import 'package:otstudio/src/screens/editor/modules/map/map_view.dart';

class Editor extends StatelessWidget {
  final Project project;

  Editor({required this.project}) {
    appWindow.minSize = null;
    appWindow.maxSize = null;
    appWindow.maximize();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: BlocProvider<ProjectBloc>(
          create: (BuildContext context) =>
              ProjectBloc(ProjectState(project: project)),
          child: Row(children: [
            MapItems(),
            // Expanded(child: MapView()),
            Expanded(
                child: Grid(
                    tree: GridTree(Composite(
                        type: GridCellType.cell,
                        children: [Leaf(value: MapView())])))),
          ])));
}
