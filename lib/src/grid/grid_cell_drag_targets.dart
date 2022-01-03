import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/grid/grid_cell_bloc.dart';

class GridCellDraggableData {
  final int index;
  final GridCellBloc bloc; // State state;

  GridCellDraggableData({required this.index, required this.bloc});
}

class GridCellDragTargets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(children: [
        _GridCellDragTarget(GridCellDragType.center),
        _GridCellDragTarget(GridCellDragType.top),
        _GridCellDragTarget(GridCellDragType.bottom),
        _GridCellDragTarget(GridCellDragType.left),
        _GridCellDragTarget(GridCellDragType.right),
      ]);
}

class _GridCellDragTarget extends StatelessWidget {
  final GridCellDragType _dragType;

  _GridCellDragTarget(this._dragType);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridCellBloc, GridCellState>(
        builder: (BuildContext context, GridCellState state) {
      Widget dragFeedback =
          Container(color: Colors.red.shade400.withOpacity(0.5));
      Widget dragTarget = DragTarget(builder: (BuildContext context,
          List<GridCellDraggableData?> candidates, List<dynamic> rejected) {
        // print('top dragtarget candidates $candidates');

        if (candidates.isNotEmpty) {
          context
              .read<GridCellBloc>()
              .add(GridCellDragged(dragType: _dragType));
          //   return Container(
          //     color: Colors.red,
          //   );
        }
        // return Container(color: Colors.blue);
        return Container();
      }, onLeave: (GridCellDraggableData? data) {
        context.read<GridCellBloc>().add(GridCellDragCancelled());
      }, onWillAccept: (GridCellDraggableData? data) {
        print('dragtarget onWillAccept');
        return willAccept(data, state);
      }, onAccept: (GridCellDraggableData? data) {
        print('top dragtarget onAccept');
        if (willAccept(data, state)) {
          context.read<GridCellBloc>().add(GridCellDropped(
              widgetIndex: data!.index,
              dragType: _dragType,
              source: data.bloc));
        }
      });

      return Stack(children: [
        Visibility(
            visible: state.dragType == _dragType,
            child: Positioned.fill(
              child:
                  _GridCellDragTargetFeedback(_dragType, child: dragFeedback),
            )),
        _GridCellDragTargetTarget(_dragType, child: dragTarget),
      ]);
    });
  }

  bool willAccept(GridCellDraggableData? data, GridCellState state) {
    if (data != null) {
      // GridCellBloc draggableBloc = data.bloc;
      GridCellState draggableState = data.bloc.state;
      if (draggableState.cols.isEmpty && draggableState.rows.isEmpty) {
        if (draggableState.widgets.length > 1 || draggableState != state) {
          return true;
        }
      }
    }
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
    _dragType = widget._dragType;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    // BlocProvider
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridCellBloc, GridCellState>(
        builder: (BuildContext context, GridCellState state) {
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
    });
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
