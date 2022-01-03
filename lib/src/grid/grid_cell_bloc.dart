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

class GridCellColRemoved extends GridCellEvent {
  int colIndex;

  GridCellColRemoved(this.colIndex);
}

class GridCellRowRemoved extends GridCellEvent {
  int rowIndex;

  GridCellRowRemoved(this.rowIndex);
}

class GridCellWidgetRemoved extends GridCellEvent {
  int widgetIndex;

  GridCellWidgetRemoved(this.widgetIndex);
}

class GridCellState {
  List<Type> widgets;
  List<GridCellBloc> cols;
  List<GridCellBloc> rows;
  GridCellDragType? dragType;

  GridCellState(
      {List<Type>? widgets,
      List<GridCellBloc>? cols,
      List<GridCellBloc>? rows,
      this.dragType})
      : this.widgets = widgets ?? [],
        this.cols = cols ?? [],
        this.rows = rows ?? [];
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
  GridCellBloc(GridCellState initialState) : super(initialState) {
    reactToChildren(state);
    // state.cols.asMap().entries.forEach((MapEntry<int, GridCellBloc> entry) {
    //   entry.value.stream.listen((GridCellState event) {
    //     // print(
    //     //     'entry.value cols ${entry.value.cols} rows ${entry.value.rows} widgets ${entry.value.state.widgets}');
    //     print(
    //         'col event cols ${entry.value.state.cols} rows ${entry.value.state.rows} widgets ${entry.value.state.widgets}');
    //     if (entry.value.isEmpty) {
    //       print('remove col at ${entry.key}');
    //       // GridCellBloc emptyCell = entry.value.state.cols. // state.cols.removeAt(entry.key);
    //       entry.value.add(GridCellRemoved(entry.key));
    //       // GridCellBloc emptyCell = state.cols.removeAt(entry.key);
    //       // emptyCell.close();
    //     }
    //   });
    // });
    // state.rows.asMap().entries.forEach((MapEntry<int, GridCellBloc> entry) {
    //   entry.value.stream.listen((GridCellState event) {
    //     // print('entry.value ${entry.value}');
    //     print(
    //         'row event cols ${entry.value.state.cols} rows ${entry.value.state.rows} widgets ${entry.value.state.widgets}');
    //     if (entry.value.isEmpty) {
    //       print('remove row at ${entry.key}');
    //       entry.value.add(GridCellRemoved(entry.key));
    //       // GridCellBloc emptyCell = this.rows.removeAt(entry.key);
    //       // emptyCell.close();
    //     }
    //   });
    // });

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
      emit(GridCellState(widgets: state.widgets, dragType: event.dragType));
    });
    on<GridCellDragCancelled>((event, emit) {
      emit(GridCellState(
        widgets: state.widgets,
      ));
    });
    on<GridCellColRemoved>((event, emit) {
      state.cols.removeAt(event.colIndex);
      if (state.cols.length == 1) {
        print('state.cols.length == 1');
        print(
            'state.cols[0] cols ${state.cols[0].state.cols} rows ${state.cols[0].state.rows} widgets ${state.cols[0].state.widgets}');
        emit(GridCellState(
          cols: state.cols[0].state.cols,
          rows: state.cols[0].state.rows,
          widgets: state.cols[0].state.widgets,
        ));
      } else {
        emit(GridCellState(
          cols: state.cols,
        ));
      }
    });
    on<GridCellRowRemoved>((event, emit) {
      state.rows.removeAt(event.rowIndex);
      if (state.rows.length == 1) {
        emit(GridCellState(
          cols: state.rows[0].state.cols,
          rows: state.rows[0].state.rows,
          widgets: state.rows[0].state.widgets,
        ));
      } else {
        emit(GridCellState(
          rows: state.rows,
        ));
      }
    });
    on<GridCellWidgetRemoved>((event, emit) {
      print(
          'gridcellremoved cols ${state.cols} rows ${state.rows} widgets ${state.widgets}');
      Type removedWidget = state.widgets.removeAt(event.widgetIndex);
      print('gridcellremoved after removed ${state.widgets}');
      emit(GridCellState(
        widgets: state.widgets,
      ));
    });
    on<GridCellDropped>((event, emit) {
      print(
          'gridCellDropped, dragType ${event.dragType}, widgets ${state.widgets}');
      Type splitWidget = event.source.state.widgets.elementAt(
          event.widgetIndex); // state.widgets.removeAt(event.widgetIndex);
      print('splitWidget $splitWidget');
      print(
          'event source cols ${event.source.state.cols} rows ${event.source.state.rows} widgets ${event.source.state.widgets}');

      List<Type> newWidgets = state.widgets;

      if (event.source == this) {
        newWidgets.removeAt(event.widgetIndex);
      } else {
        event.source.add(GridCellWidgetRemoved(event.widgetIndex));
      }

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
            GridCellBloc(GridCellState(widgets: [splitWidget])),
            GridCellBloc(GridCellState(widgets: newWidgets)),
          ]));
          break;
        case GridCellDragType.right:
          emit(GridCellState(cols: [
            GridCellBloc(GridCellState(widgets: newWidgets)),
            GridCellBloc(GridCellState(widgets: [splitWidget])),
          ]));
          break;
        case GridCellDragType.top:
          emit(GridCellState(rows: [
            GridCellBloc(GridCellState(widgets: [splitWidget])),
            GridCellBloc(GridCellState(widgets: newWidgets)),
          ]));
          break;
        case GridCellDragType.bottom:
          emit(GridCellState(rows: [
            GridCellBloc(GridCellState(widgets: newWidgets)),
            GridCellBloc(GridCellState(widgets: [splitWidget])),
          ]));
          break;
        case GridCellDragType.center:
          emit(GridCellState(widgets: [
            ...newWidgets,
            splitWidget,
          ]));
          break;
      }
    });
  }

  bool get isEmpty =>
      state.cols.isEmpty && state.rows.isEmpty && state.widgets.isEmpty;

  @override
  void onChange(Change<GridCellState> change) {
    print(
        'onChange next cols ${change.nextState.cols} rows ${change.nextState.rows} widgets ${change.nextState.widgets}');
    super.onChange(change);

    reactToChildren(change.nextState);

    // change.nextState.cols
    //     .asMap()
    //     .entries
    //     .forEach((MapEntry<int, GridCellBloc> entry) {
    //   entry.value.stream.listen((GridCellState event) {
    //     // print(
    //     //     'entry.value cols ${entry.value.cols} rows ${entry.value.rows} widgets ${entry.value.state.widgets}');
    //     print(
    //         'col event cols ${entry.value.state.cols} rows ${entry.value.state.rows} widgets ${entry.value.state.widgets}');
    //     if (entry.value.isEmpty) {
    //       print('remove col at ${entry.key}');
    //       // GridCellBloc emptyCell = entry.value.state.cols. // state.cols.removeAt(entry.key);
    //       add(GridCellColRemoved(entry.key));
    //       // entry.value.add(GridCellColRemoved(entry.key));
    //       // GridCellBloc emptyCell = state.cols.removeAt(entry.key);
    //       // emptyCell.close();
    //     }
    //   });
    // });
    // change.nextState.rows
    //     .asMap()
    //     .entries
    //     .forEach((MapEntry<int, GridCellBloc> entry) {
    //   entry.value.stream.listen((GridCellState event) {
    //     // print('entry.value ${entry.value}');
    //     print(
    //         'row event cols ${entry.value.state.cols} rows ${entry.value.state.rows} widgets ${entry.value.state.widgets}');
    //     if (entry.value.isEmpty) {
    //       print('remove row at ${entry.key}');
    //       add(GridCellRowRemoved(entry.key));
    //       // entry.value.add(GridCellRemoved(entry.key));
    //       // GridCellBloc emptyCell = this.rows.removeAt(entry.key);
    //       // emptyCell.close();
    //     }
    //   });
    // });
  }

  void reactToChildren(GridCellState state) {
    state.cols.asMap().entries.forEach((MapEntry<int, GridCellBloc> entry) {
      reactToChild(entry.value, GridCellColRemoved(entry.key));
      // entry.value.stream.listen((GridCellState event) {
      //   // print(
      //   //     'entry.value cols ${entry.value.cols} rows ${entry.value.rows} widgets ${entry.value.state.widgets}');
      //   print(
      //       'col event cols ${entry.value.state.cols} rows ${entry.value.state.rows} widgets ${entry.value.state.widgets}');
      //   if (entry.value.isEmpty) {
      //     print('remove col at ${entry.key}');
      //     // GridCellBloc emptyCell = entry.value.state.cols. // state.cols.removeAt(entry.key);
      //     add(GridCellColRemoved(entry.key));
      //     // entry.value.add(GridCellColRemoved(entry.key));
      //     // GridCellBloc emptyCell = state.cols.removeAt(entry.key);
      //     // emptyCell.close();
      //   }
      // });
    });
    state.rows.asMap().entries.forEach((MapEntry<int, GridCellBloc> entry) {
      reactToChild(entry.value, GridCellRowRemoved(entry.key));
      // entry.value.stream.listen((GridCellState event) {
      //   // print('entry.value ${entry.value}');
      //   print(
      //       'row event cols ${entry.value.state.cols} rows ${entry.value.state.rows} widgets ${entry.value.state.widgets}');
      //   if (entry.value.isEmpty) {
      //     print('remove row at ${entry.key}');
      //     add(GridCellRowRemoved(entry.key));
      //     // entry.value.add(GridCellRemoved(entry.key));
      //     // GridCellBloc emptyCell = this.rows.removeAt(entry.key);
      //     // emptyCell.close();
      //   }
      // });
    });
  }

  void reactToChild(GridCellBloc childBloc, GridCellEvent event) {
    childBloc.stream.listen((_) {
      // print(
      //     'entry.value cols ${entry.value.cols} rows ${entry.value.rows} widgets ${entry.value.state.widgets}');
      print(
          'reactToChild cols ${childBloc.state.cols} rows ${childBloc.state.rows} widgets ${childBloc.state.widgets}');
      if (childBloc.isEmpty) {
        // print('remove col at ${event.index}');
        // GridCellBloc emptyCell = entry.value.state.cols. // state.cols.removeAt(entry.key);
        add(event);
        // entry.value.add(GridCellColRemoved(entry.key));
        // GridCellBloc emptyCell = state.cols.removeAt(entry.key);
        // emptyCell.close();
      }
    });
  }
}
