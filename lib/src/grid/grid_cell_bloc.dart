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
  GridCellBloc source;

  GridCellDropped({
    required this.widgetIndex,
    this.dragType = GridCellDragType.center,
    required this.source,
  });
}

class GridCellRemoved extends GridCellEvent {
  int widgetIndex;

  GridCellRemoved(this.widgetIndex);
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
  GridCellBloc? parent;

  GridCellBloc(GridCellState initialState, [this.parent])
      : super(initialState) {
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
    on<GridCellRemoved>((event, emit) {
      if (parent != null) {
        print(
            'parent col ${parent!.state.cols.any((col) => col.hashCode == state.hashCode)}');
        print(
            'parent row ${parent!.state.rows.any((row) => row.hashCode == state.hashCode)}');
        // print('parent widget ${parent!.state.widgets.any((widget) => widget == state)}');
      }

      emit(GridCellState(
        cols: state.cols,
        rows: state.rows,
        widgets: state.widgets
            .asMap()
            .entries
            .where((entry) => entry.key != event.widgetIndex)
            .map((entry) => entry.value)
            .toList(),
      ));
    });
    on<GridCellDropped>((event, emit) {
      print(
          'gridCellDropped, dragType ${event.dragType}, widgets ${state.widgets}');
      Type splitWidget = event.source.state.widgets.elementAt(
          event.widgetIndex); // state.widgets.removeAt(event.widgetIndex);
      print('splitWidget $splitWidget');

      event.source.add(GridCellRemoved(event.widgetIndex));

      // event.source.emit(GridCellState(
      //   cols: state.cols,
      //   rows: state.rows,
      //   widgets: state.widgets
      //       .asMap()
      //       .entries
      //       .where((entry) => entry.key != event.widgetIndex)
      //       .map((entry) => entry.value)
      //       .toList(),
      // ));

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
        case GridCellDragType.center:
          emit(GridCellState(widgets: [
            ...state.widgets,
            splitWidget,
          ]));
          break;
      }
    });
  }
}
