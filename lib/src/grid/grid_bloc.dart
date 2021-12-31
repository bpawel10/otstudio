import 'package:flutter_bloc/flutter_bloc.dart';
import 'grid_cell_bloc.dart';
import '../test_widget.dart';

abstract class GridEvent {}

class GridState extends GridCellState {
  GridState({required List<Type> widgets}) : super(widgets: widgets);
}

class GridBloc extends Bloc<GridEvent, GridState> {
  GridBloc() : super(GridState(widgets: [TestWidget]));
}
