import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_cell_bloc.dart';
import 'package:otstudio/src/grid/grid_widget.dart';
import 'package:otstudio/src/test_widget.dart';

class GridDraggableData {
  final int index;
  final GridCellState state;

  GridDraggableData({required this.index, required this.state});
}

class GridCell extends StatelessWidget {
  final GridCellState parentState;

  GridCell({required this.parentState});

  @override
  Widget build(BuildContext context) {
    print('gridcell builder');
    print('parentState $parentState');

    if (parentState.cols.isNotEmpty) {
      print('parentState cols not empty');
      return Row(
        children: parentState.cols
            .map((cell) => GridCell(parentState: cell))
            .toList(),
      );
    } else if (parentState.rows.isNotEmpty) {
      print('parentState rows not empty');
      return Column(
        children: parentState.rows
            .map((cell) => GridCell(parentState: cell))
            .toList(),
      );
    } else {
      return Column(
        children: [
          BlocBuilder<GridCellBloc, GridCellState>(
              builder: (BuildContext blocContext, GridCellState state) {
            print('gridcellbloc builder');
            return Row(
              children: [
                ...state.widgets.asMap().entries.map(
                    (MapEntry<int, Type> entry) => Draggable(
                        data: GridDraggableData(index: entry.key, state: state),
                        feedback: SizedBox(
                            height: 50, child: Text(entry.value.toString())),
                        child: SizedBox(
                            height: 50, child: Text(entry.value.toString())))),
                TextButton(
                    child: Text('+'),
                    onPressed: () => blocContext
                        .read<GridCellBloc>()
                        .add(AddGridWidgetPressed())),
              ],
            );
          }),
          Expanded(child: DragTarget(builder: (BuildContext context,
              List<GridDraggableData?> candidates, List<dynamic> rejected) {
            print('top dragtarget candidates $candidates');
            if (candidates.isEmpty) {
              context.read<GridCellBloc>().add(GridCellDragCancelled());
            }
            return Stack(
              children: [
                TestWidget(),
                BlocBuilder<GridCellBloc, GridCellState>(
                    builder: (BuildContext blocContext, GridCellState state) {
                  print('state.dragType ${state.dragType}');
                  return Visibility(
                      visible: state.dragType == GridCellDragType.left,
                      child: Positioned.fill(
                          child: FractionallySizedBox(
                        widthFactor: 0.5,
                        alignment: Alignment.centerLeft,
                        child: Container(
                            color: Colors.red.shade200.withOpacity(0.5)),
                      )));
                }),
                BlocBuilder<GridCellBloc, GridCellState>(
                    builder: (BuildContext blocContext, GridCellState state) {
                  print('state.dragType ${state.dragType}');
                  return Positioned.fill(
                      child: Visibility(
                          visible: state.dragType == GridCellDragType.right,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.centerRight,
                            child: Container(
                                color: Colors.red.shade200.withOpacity(0.5)),
                          )));
                }),
                BlocBuilder<GridCellBloc, GridCellState>(
                    builder: (BuildContext blocContext, GridCellState state) {
                  print('state.dragType ${state.dragType}');
                  return Visibility(
                      visible: state.dragType == GridCellDragType.top,
                      child: Positioned.fill(
                          child: FractionallySizedBox(
                        heightFactor: 0.5,
                        alignment: Alignment.topCenter,
                        child: Container(
                            color: Colors.red.shade200.withOpacity(0.5)),
                      )));
                }),
                BlocBuilder<GridCellBloc, GridCellState>(
                    builder: (BuildContext blocContext, GridCellState state) {
                  print('state.dragType ${state.dragType}');
                  return Visibility(
                      visible: state.dragType == GridCellDragType.bottom,
                      child: Positioned.fill(
                          child: FractionallySizedBox(
                        heightFactor: 0.5,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            color: Colors.red.shade200.withOpacity(0.5)),
                      )));
                }),
                BlocBuilder<GridCellBloc, GridCellState>(
                    builder: (BuildContext blocContext, GridCellState state) {
                  print('state.dragType ${state.dragType}');
                  return Visibility(
                    visible: state.dragType == GridCellDragType.center,
                    child: Positioned.fill(
                        child: Container(
                            color: Colors.red.shade200.withOpacity(0.5))),
                  );
                }),
                DragTarget(builder: (BuildContext context,
                    List<GridDraggableData?> candidates,
                    List<dynamic> rejected) {
                  print('center dragtarget candidates $candidates');
                  if (candidates.isNotEmpty) {
                    context.read<GridCellBloc>().add(
                        GridCellDragged(dragType: GridCellDragType.center));
                    //   return Container(
                    //     color: Colors.red,
                    //   );
                  }
                  // return Container(color: Colors.yellow);
                  return Container();
                }),
                Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        height: 100,
                        child: DragTarget(
                          builder: (BuildContext context,
                              List<GridDraggableData?> candidates,
                              List<dynamic> rejected) {
                            print('top dragtarget candidates $candidates');
                            if (candidates.isNotEmpty) {
                              context.read<GridCellBloc>().add(GridCellDragged(
                                  dragType: GridCellDragType.top));
                              //   return Container(
                              //     color: Colors.red,
                              //   );
                            }
                            // return Container(color: Colors.blue);
                            return Container();
                          },
                          onWillAccept: (GridDraggableData? data) {
                            print('top dragtarget onWillAccept');
                            return true;
                          },
                          onAccept: (GridDraggableData? data) {
                            print('top dragtarget onAccept');
                            int? index = data?.index;
                            if (index != null) {
                              context.read<GridCellBloc>().add(GridCellDropped(
                                  widgetIndex: index,
                                  dragType: GridCellDragType.top));
                            }
                          },
                        ))),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                        height: 100,
                        child: DragTarget(
                          builder: (BuildContext context,
                              List<GridDraggableData?> candidates,
                              List<dynamic> rejected) {
                            if (candidates.isNotEmpty) {
                              context.read<GridCellBloc>().add(GridCellDragged(
                                  dragType: GridCellDragType.bottom));
                              //   return Container(
                              //     color: Colors.red,
                              //   );
                            }
                            // return Container(color: Colors.blue);
                            return Container();
                          },
                          onWillAccept: (GridDraggableData? data) {
                            print('bottom dragtarget onWillAccept');
                            return true;
                          },
                          onAccept: (GridDraggableData? data) {
                            print('bottom dragtarget onAccept');
                            int? index = data?.index;
                            if (index != null) {
                              context.read<GridCellBloc>().add(GridCellDropped(
                                  widgetIndex: index,
                                  dragType: GridCellDragType.bottom));
                            }
                          },
                        ))),
                Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                        width: 100,
                        child: DragTarget(
                          builder: (BuildContext context,
                              List<GridDraggableData?> candidates,
                              List<dynamic> rejected) {
                            if (candidates.isNotEmpty) {
                              context.read<GridCellBloc>().add(GridCellDragged(
                                  dragType: GridCellDragType.left));

                              //   return Container(
                              //     color: Colors.red,
                              //   );
                            }
                            // return Container(color: Colors.blue);
                            return Container();
                          },
                          onWillAccept: (GridDraggableData? data) {
                            print('left dragtarget onWillAccept');
                            return true;
                          },
                          onAccept: (GridDraggableData? data) {
                            print('left dragtarget onAccept');
                            int? index = data?.index;
                            if (index != null) {
                              context.read<GridCellBloc>().add(GridCellDropped(
                                  widgetIndex: index,
                                  dragType: GridCellDragType.left));
                            }
                          },
                        ))),
                Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                        width: 100,
                        child: DragTarget(
                          builder: (BuildContext context,
                              List<GridDraggableData?> candidates,
                              List<dynamic> rejected) {
                            if (candidates.isNotEmpty) {
                              context.read<GridCellBloc>().add(GridCellDragged(
                                  dragType: GridCellDragType.right));
                              //   return Container(
                              //     color: Colors.red,
                              //   );
                            }
                            // return Container(color: Colors.blue);
                            return Container();
                          },
                          onWillAccept: (GridDraggableData? data) {
                            print('right dragtarget onWillAccept');
                            return true;
                          },
                          onAccept: (GridDraggableData? data) {
                            print('right dragtarget onAccept');
                            int? index = data?.index;
                            if (index != null) {
                              context.read<GridCellBloc>().add(GridCellDropped(
                                  widgetIndex: index,
                                  dragType: GridCellDragType.right));
                            }
                          },
                        ))),
                // DragTarget(builder: (BuildContext context,
                //     List<GridDraggableData?> candidates,
                //     List<dynamic> rejected) {
                //   print('last dragtarget candidates $candidates');
                //   if (candidates.isEmpty) {
                //     context.read<GridCellBloc>().add(GridCellDragCancelled());
                //     //   return Container(
                //     //     color: Colors.red,
                //     //   );
                //   }
                //   // return Container(color: Colors.yellow);
                //   return Container();
                // }),
              ],
            );
          })),
        ],
      );
    }
  }
}

             //     print('dragtarget builder');
                      //     print('candidates $candidates');
                      //     return BlocBuilder<GridCellBloc, GridCellState>(
                      //         builder: (BuildContext blocContext,
                      //             GridCellState state) {
                      //       if (candidates.isNotEmpty &&
                      //           state.widgets.length > 1) {
                      //         return Container(
                      //           color: Colors.red,
                      //         );
                      //       }
                      //       return Container(
                      //         color: Colors.blue,
                      //       );
                      //     });
                      //   },
                      //   onWillAccept: (GridDraggableData? data) {
                      //     print('onWillAccept');
                      //     return true;
                      //   },
                      //   onAccept: (GridDraggableData? data) {
                      //     print('onAccept');
                      //     int? index = data?.index;
                      //     if (index != null) {
                      //       context
                      //           .read<GridCellBloc>()
                      //           .add(SplitGridCellRight(index));
                      //     }
                      //   },
                      // ))),