// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'grid_cell_bloc.dart';
// import '../test_widget.dart';

// abstract class GridEvent {}

// enum GridCellType { column, row, cell }

// class GridCellState {
//   GridCellType type;
//   List<GridCellState> children;

//   GridCellState({required this.type, required this.children});
// }

// class GridBloc extends Bloc<GridEvent, GridCellState> {
//   GridBloc()
//       : super(GridCellState(cols: [
//           GridCellState(widgets: [TestWidget, TestWidget]),
//           GridCellState(widgets: [TestWidget])
//         ]));
// }
