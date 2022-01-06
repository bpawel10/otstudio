import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/test_widget.dart';
import 'package:otstudio/src/test_widget2.dart';
import 'package:otstudio/src/test_widget3.dart';
import 'grid_cell_bloc.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocProvider(
        create: (BuildContext context) => GridCellBloc(GridCellState(cols: [
              GridCellBloc(GridCellState(widgets: [TestWidget, TestWidget2])),
              GridCellBloc(GridCellState(widgets: [TestWidget3])),
            ])),
        child: GridCell());
  }
}
