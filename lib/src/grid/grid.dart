import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'grid_bloc.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocBuilder<GridBloc, GridState>(
        builder: (BuildContext context, GridState state) {
      print('grid builder');
      return GridCell(parentState: state);
    });
  }
}
