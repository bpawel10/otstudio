import 'package:flutter_bloc/flutter_bloc.dart';
import '../test_widget.dart';

enum GridCellDragType { left, right, top, bottom, center }

abstract class GridCellEvent {}

class AddGridWidgetPressed extends GridCellEvent {}

class GridCellDragged extends GridCellEvent {
  GridCellDragType dragType;

  GridCellDragged({this.dragType = GridCellDragType.center});
}

class GridCellDragCancelled extends GridCellEvent {}

class GridCellDropped extends GridCellEvent {
  int widgetIndex;
  GridCellDragType dragType;

  GridCellDropped(
      {required this.widgetIndex, this.dragType = GridCellDragType.center});
}

class GridCellState {
  List<Type> widgets;
  List<GridCellState> cols;
  List<GridCellState> rows;
  GridCellDragType? dragType;

  GridCellState(
      {this.widgets = const [],
      this.cols = const [],
      this.rows = const [],
      this.dragType});
}

// class GridColumnCell extends GridCellState {
//   List<GridCellState> cells;

//   GridColumnCell({required this.cells});
// }

// class GridRowCell extends GridCellState {
//   List<GridCellState> cells;

//   GridRowCell({required this.cells});
// }

class GridCellBloc extends Bloc<GridCellEvent, GridCellState> {
  GridCellBloc() : super(GridCellState()) {
    on<AddGridWidgetPressed>((event, emit) {
      print('onAddGridWidgetPressed');
      // if (!(state is GridColumnCell) && !(state is GridRowCell)) {
      print('state.widgets.length ${state.widgets.length}');
      // state.widgets.add(TestWidget);
      print('state.widgets.length2 ${state.widgets.length}');
      // emit(state);
      emit(GridCellState(widgets: [...state.widgets, TestWidget]));
      // }
    });
    on<GridCellDragged>((event, emit) {
      print('onGridCellDragged ${event.dragType}');
      emit(GridCellState(
          cols: state.cols,
          rows: state.rows,
          widgets: state.widgets,
          dragType: event.dragType));
    });
    on<GridCellDragCancelled>((event, emit) {
      emit(GridCellState(
        cols: state.cols,
        rows: state.rows,
        widgets: state.widgets,
      ));
    });
    on<GridCellDropped>((event, emit) {
      print(
          'gridCellDropped, dragType ${event.dragType}, widgets ${state.widgets}');
      Type splitWidget = state.widgets.removeAt(event.widgetIndex);
      print('splitWidget $splitWidget');
      switch (event.dragType) {
        case GridCellDragType.left:
          emit(GridCellState(cols: [
            GridCellState(widgets: [splitWidget]),
            GridCellState(widgets: state.widgets),
          ]));
          break;
        case GridCellDragType.right:
          emit(GridCellState(cols: [
            GridCellState(widgets: state.widgets),
            GridCellState(widgets: [splitWidget]),
          ]));
          break;
        case GridCellDragType.top:
          emit(GridCellState(rows: [
            GridCellState(widgets: [splitWidget]),
            GridCellState(widgets: state.widgets),
          ]));
          break;
        case GridCellDragType.bottom:
          emit(GridCellState(rows: [
            GridCellState(widgets: state.widgets),
            GridCellState(widgets: [splitWidget]),
          ]));
          break;
        // TODO: handle dragging widget from one cell to another (but without splitting)
        // case GridCellDragType.center:
        //   emit(GridCellState(widgets: [
        //     ...state.widgets,
        //     splitWidget,
        //   ]));
        //  break;
      }
    });
  }
}
