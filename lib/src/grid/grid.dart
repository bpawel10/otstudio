import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/grid/tree.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocProvider<GridBloc>(
        create: (BuildContext context) {
          return GridBloc(GridState(
              tree: GridTree(Composite(
            type: GridCellType.row,
            children: [
              Composite(type: GridCellType.cell, children: [
                Leaf(value: Container()),
                Leaf(value: Container())
              ]),
              Composite(
                  type: GridCellType.cell,
                  children: [Leaf(value: Container())]),
            ],
          ))));
        },
        child: GridCell([]));
  }
}
