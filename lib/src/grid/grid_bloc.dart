import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell_drag_targets.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/test_widget.dart';

abstract class GridEvent {}

class GridCellDragged extends GridEvent {
  List<int> target;
  GridCellDragType type;

  GridCellDragged({required this.target, required this.type});
}

class GridCellDragCancelled extends GridEvent {
  List<int> target;

  GridCellDragCancelled({required this.target});
}

class GridCellDropped extends GridEvent {
  List<int> source;
  List<int> target;
  GridCellDragType type;

  GridCellDropped(
      {required this.source, required this.target, required this.type});
}

class AddGridWidgetPressed extends GridEvent {
  List<int> path;

  AddGridWidgetPressed({required this.path});
}

class GridCellDrag {
  List<int> target;
  GridCellDragType type;

  GridCellDrag({required this.target, required this.type});
}

class GridState {
  GridTree tree;
  GridCellDrag? drag;

  GridState({required this.tree, this.drag});
}

class GridBloc extends Bloc<GridEvent, GridState> {
  GridBloc(GridState initialState) : super(initialState) {
    on<GridCellDragged>((event, emit) {
      emit(GridState(
          tree: state.tree,
          drag: GridCellDrag(target: event.target, type: event.type)));
    });
    on<GridCellDragCancelled>((event, emit) {
      emit(GridState(tree: state.tree));
    });
    on<GridCellDropped>((event, emit) {
      GridTree tree = GridTree.from(state.tree);

      switch (event.type) {
        case GridCellDragType.left:
          tree.splitLeft(event.source, event.target);
          break;
        case GridCellDragType.right:
          tree.splitRight(event.source, event.target);
          break;
        case GridCellDragType.top:
          tree.splitTop(event.source, event.target);
          break;
        case GridCellDragType.bottom:
          tree.splitBottom(event.source, event.target);
          break;
        case GridCellDragType.center:
          tree.move(event.source, event.target);
          break;
      }

      tree.removeEmptyForOne(event.source);
      // tree.removeEmptyForAll(event.source..removeLast());

      emit(GridState(tree: tree));
    });
    on<AddGridWidgetPressed>((event, emit) {
      emit(
        GridState(tree: GridTree.from(state.tree..add(event.path, TestWidget))),
      );
    });
  }
}
