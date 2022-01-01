import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'grid_cell_bloc.dart';
import 'grid_bloc.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocBuilder<GridBloc, GridCellState>(
        builder: (BuildContext context, GridCellState state) {
      print('grid builder');
      return GridCell(parentState: state);
    });
  }
}
