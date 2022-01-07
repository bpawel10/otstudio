import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/grid/tree.dart';
import 'package:otstudio/src/test_widget.dart';
import 'package:otstudio/src/test_widget2.dart';
import 'package:otstudio/src/test_widget3.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocProvider(
        create: (BuildContext context) {
          return GridBloc(GridState(
              tree: GridTree(Composite(
            type: GridCellType.row,
            children: [
              Composite(type: GridCellType.cell, children: [
                Leaf(value: TestWidget),
                Leaf(value: TestWidget2)
              ]),
              Composite(
                  type: GridCellType.cell,
                  children: [Leaf(value: TestWidget3)]),
            ],
          ))));
        },
        child: GridCell([]));
  }
}
