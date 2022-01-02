import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/test_widget.dart';
import 'grid_cell_bloc.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocProvider(
        create: (BuildContext context) => GridCellBloc(GridCellState(cols: [
              GridCellState(widgets: [TestWidget, TestWidget]),
              GridCellState(widgets: [TestWidget])
            ])),
        child: GridCell());
  }
}
