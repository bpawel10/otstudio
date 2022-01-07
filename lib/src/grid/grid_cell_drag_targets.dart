import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/grid/tree.dart';
import 'dart:collection';

class GridCellDraggableData {
  final List<int> path;

  GridCellDraggableData({required this.path});
}

enum GridCellDragType { left, right, top, bottom, center }

class GridCellDragTargets extends StatelessWidget {
  final List<int> path;

  GridCellDragTargets(this.path);

  @override
  Widget build(BuildContext context) => Stack(children: [
        _GridCellDragTarget(path: path, dragType: GridCellDragType.center),
        _GridCellDragTarget(path: path, dragType: GridCellDragType.top),
        _GridCellDragTarget(path: path, dragType: GridCellDragType.bottom),
        _GridCellDragTarget(path: path, dragType: GridCellDragType.left),
        _GridCellDragTarget(path: path, dragType: GridCellDragType.right),
      ]);
}

class _GridCellDragTarget extends StatelessWidget {
  final List<int> path;
  final GridCellDragType dragType;

  _GridCellDragTarget({required this.path, required this.dragType});

  @override
  Widget build(BuildContext context) {
    print('dragtarget path $path');
    GridBloc grid = context.read<GridBloc>();
    GridTree tree = grid.state.tree;
    GridCellDrag? drag = grid.state.drag;

    Widget dragFeedback =
        Container(color: Colors.red.shade400.withOpacity(0.5));
    Widget dragTarget = DragTarget(builder: (BuildContext context,
        List<GridCellDraggableData?> candidates, List<dynamic> rejected) {
      // print('top dragtarget candidates $candidates');

      if (candidates.isNotEmpty) {
        grid.add(GridCellDragged(target: path, type: dragType));
        //   return Container(
        //     color: Colors.red,
        //   );
      }
      // return Container(color: Colors.blue);
      return Container();
    }, onLeave: (GridCellDraggableData? data) {
      grid.add(GridCellDragCancelled(target: path));
    }, onWillAccept: (GridCellDraggableData? data) {
      print('dragtarget onWillAccept $data');
      return willAccept(data, tree);
    }, onAccept: (GridCellDraggableData? data) {
      print('top dragtarget onAccept');
      if (willAccept(data, tree)) {
        grid.add(
            GridCellDropped(source: data!.path, target: path, type: dragType));
        // GridCellBloc sourceBloc = data!.bloc;
        // GridCellBloc targetBloc = context.read<GridCellBloc>();
        // int index = data.index;
        // Type widget = sourceBloc.state.widgets[index];
        // if (sourceBloc != targetBloc) {
        //   print('sourceBloc.add(gridcellwidgetremoved(index: ${data.index}');
        //   sourceBloc.add(GridCellWidgetRemoved(data.index));
        //   index--;
        // }
        // context
        //     .read<GridCellBloc>()
        //     .add(GridCellDropped(dragType: _dragType, widget: widget));
      }
    });

    print(
        'drag.target ${drag?.target} path $path, equal ${drag?.target == path}');

    return Stack(children: [
      Visibility(
          visible: drag != null &&
              ListEquality().equals(drag.target, path) &&
              drag.type == dragType,
          child: Positioned.fill(
            child: _GridCellDragTargetFeedback(dragType, child: dragFeedback),
          )),
      _GridCellDragTargetTarget(dragType, child: dragTarget),
    ]);
  }

  bool willAccept(GridCellDraggableData? data, GridTree tree) {
    print('willAccept data path ${data?.path} path $path');
    if (data != null && data.path.isNotEmpty) {
      // Node sourceNode = tree.getNode(data.path);
      List<int> sourceParentPath = List.from(data.path)..removeLast();
      Composite<GridCellType> sourceParentNode =
          tree.getNode(sourceParentPath) as Composite<GridCellType>;
      print('sourceParentNode.children ${sourceParentNode.children}');
      // Node targetNode = tree.getNode(path);
      if (sourceParentNode.type == GridCellType.cell &&
          (!ListEquality().equals(sourceParentPath, path) ||
              (dragType != GridCellDragType.center &&
                  sourceParentNode.children.length > 1))) {
        print('return true');
        return true;
      }

      // GridTree tree = context.read<GridBloc>();
      // GridCellBloc draggableBloc = data.bloc;
      // GridCellState draggableState = data.bloc.state;
      // if (draggableState.cols.isEmpty && draggableState.rows.isEmpty) {
      //   if (draggableState.widgets.length > 1 || draggableState != state) {
      //     return true;
      //   }
      // }
    }
    print('return false');
    return false;
  }
}

class _GridCellDragTargetFeedback extends StatefulWidget {
  static const double factor = 0.5;
  final Widget child;
  final GridCellDragType _dragType;

  _GridCellDragTargetFeedback(this._dragType, {required this.child});

  @override
  State<StatefulWidget> createState() => _GridCellDragTargetFeedbackState();
}

class _GridCellDragTargetFeedbackState
    extends State<_GridCellDragTargetFeedback>
    with SingleTickerProviderStateMixin {
  late GridCellDragType _dragType;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _dragType = widget._dragType;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    // BlocProvider
  }

  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<GridCellBloc, GridCellState>(
    //     builder: (BuildContext context, GridCellState state) {
    switch (_dragType) {
      case GridCellDragType.left:
        // return AnimatedContainer(
        //   duration: Duration(seconds: 1),
        //   alignment: Alignment.centerLeft,
        //   width: context.size.width * widget.factor,
        // );
        return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _GridCellDragTargetFeedback.factor,
            child: widget.child);
      case GridCellDragType.right:
        return FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: _GridCellDragTargetFeedback.factor,
            child: widget.child);
      case GridCellDragType.top:
        return FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: _GridCellDragTargetFeedback.factor,
            child: widget.child);
      case GridCellDragType.bottom:
        return FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: _GridCellDragTargetFeedback.factor,
            child: widget.child);
      case GridCellDragType.center:
        // return AnimatedContainer(
        //   duration: Duration(seconds: 1),
        //   alignment: Alignment.centerLeft,
        //   width: context.size.width * widget.factor,
        // );
        return widget.child;
    }
    // });
    // listenWhen: (previous, current) =>
    //     previous.dragType != current.dragType);
  }
}

class _GridCellDragTargetTarget extends StatelessWidget {
  static const double size = 50;
  final Widget child;
  final GridCellDragType _dragType;

  _GridCellDragTargetTarget(this._dragType, {required this.child});

  @override
  Widget build(BuildContext context) {
    switch (_dragType) {
      case GridCellDragType.left:
        return Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: size, child: child));
      case GridCellDragType.right:
        return Align(
            alignment: Alignment.centerRight,
            child: SizedBox(width: size, child: child));
      case GridCellDragType.top:
        return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(height: size, child: child));
      case GridCellDragType.bottom:
        return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(height: size, child: child));
      case GridCellDragType.center:
        return child;
    }
  }
}
