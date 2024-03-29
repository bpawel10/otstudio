import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_cell_drag_targets.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/grid/tree.dart';

class GridCell extends StatelessWidget {
  final List<int> path;

  GridCell(this.path);

  @override
  Widget build(BuildContext context) {
    // print('gridcell builder (id: $id)');
    return BlocBuilder<GridBloc, GridState>(
        builder: (BuildContext context, GridState state) {
      GridBloc grid = context.read<GridBloc>();
      // print('gridcell builder (id: $id) state.tree ${state.tree}');
      // // print(jsonEncode(state.tree.nodes));
      // inspect(state.tree.nodes);

      Composite<GridCellType> cell =
          state.tree.getNode(path) as Composite<GridCellType>;

      print('gridcell path $path cell $cell children ${cell.children}');

      switch (cell.type) {
        case GridCellType.column:
          return Column(
              children: cell.children.mapIndexed((int index, Node child) {
            Widget cellWidget = Stack(children: [
              GridCell([...path, index]),
              Visibility(
                  visible: index > 0,
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                          height: 5,
                          child:
                              Container(color: Colors.blue.withOpacity(0.2))))),
              Visibility(
                  visible: index < cell.children.length - 1,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                          height: 5,
                          child:
                              Container(color: Colors.blue.withOpacity(0.2))))),
            ]);

            if (child is Composite<GridCellType> && child.size != null) {
              return SizedBox(height: child.size, child: cellWidget);
            }
            return Expanded(child: cellWidget);
          }).toList());
        case GridCellType.row:
          return Row(
              children: cell.children
                  .mapIndexed(
                    (int index, Node child) =>
                        Expanded(child: GridCell([...path, index])),
                  )
                  .toList());
        case GridCellType.cell:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (path.every((element) => element == 0))
                        // SizedBox(width: 70),
                        ...cell.children.mapIndexed((int index, Node child) {
                          Widget widget = (child as Leaf).value;
                          return Draggable(
                              data:
                                  GridCellDraggableData(path: [...path, index]),
                              feedback: SizedBox(
                                  height: 28,
                                  child: Material(
                                      child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      width: 2))),
                                          // decoration: BoxDecoration(
                                          //     color: Colors.grey.shade700),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                widget.toString(),
                                                //  textAlign: TextAlign.center,
                                              ))))),
                              child: SizedBox(
                                  height: 35,
                                  child: Column(children: [
                                    SizedBox(height: 4),
                                    Expanded(
                                        child: Row(children: [
                                      Container(
                                          width: 10,
                                          color: Theme.of(context).primaryColor,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade900,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10))))),
                                      Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                          // decoration: BoxDecoration(
                                          //     color: Colors.grey.shade500,
                                          //     border: Border(
                                          //         bottom: BorderSide(
                                          //             color: Theme.of(context)
                                          //                 .primaryColor,
                                          //             width: 2))),
                                          // decoration: BoxDecoration(
                                          //     color: Colors.grey.shade700),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                widget.toString(),
                                                //  textAlign: TextAlign.center,
                                              ))),
                                      Container(
                                          width: 10,
                                          color: Theme.of(context).primaryColor,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade900,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10))))),
                                    ]))
                                  ])));
                        }),
                      // IconButton(
                      //     icon: Icon(Icons.add),
                      //     onPressed: () =>
                      //         grid.add(AddGridWidgetPressed(path: path))),
                    ],
                  )),
              Expanded(
                  child: Stack(
                children: [
                  (cell.children.first as Leaf<Widget>).value,
                  Positioned.fill(child: GridCellDragTargets(path)),
                  // Visibility(
                  //     visible: state.dragType == GridCellDragType.left,
                  //     child: Positioned.fill(
                  //         child: FractionallySizedBox(
                  //       widthFactor: 0.5,
                  //       alignment: Alignment.centerLeft,
                  //       child: Container(
                  //           color: Colors.red.shade400.withOpacity(0.5)),
                  //     ))),

                  // Visibility(
                  //     visible: state.dragType == GridCellDragType.right,
                  //     child: Positioned.fill(
                  //         child: FractionallySizedBox(
                  //       widthFactor: 0.5,
                  //       alignment: Alignment.centerRight,
                  //       child: Container(
                  //           color: Colors.red.shade400.withOpacity(0.5)),
                  //     ))),

                  // Visibility(
                  //     visible: state.dragType == GridCellDragType.top,
                  //     child: Positioned.fill(
                  //         child: FractionallySizedBox(
                  //       heightFactor: 0.5,
                  //       alignment: Alignment.topCenter,
                  //       child: Container(
                  //           color: Colors.red.shade400.withOpacity(0.5)),
                  //     ))),

                  // Visibility(
                  //     visible: state.dragType == GridCellDragType.bottom,
                  //     child: Positioned.fill(
                  //         child: FractionallySizedBox(
                  //       heightFactor: 0.5,
                  //       alignment: Alignment.bottomCenter,
                  //       child: Container(
                  //           color: Colors.red.shade400.withOpacity(0.5)),
                  //     ))),

                  // Visibility(
                  //   visible: state.dragType == GridCellDragType.center,
                  //   child: Positioned.fill(
                  //       child: Container(
                  //           color: Colors.red.shade400.withOpacity(0.5))),
                  // ),

                  // DragTarget(builder: (BuildContext context,
                  //     List<GridDraggableData?> candidates,
                  //     List<dynamic> rejected) {
                  //   // print('center dragtarget candidates $candidates');
                  //   if (candidates.isNotEmpty) {
                  //     // context.bloc<>
                  //     context.read<GridCellBloc>().add(
                  //         GridCellDragged(dragType: GridCellDragType.center));
                  //     //   return Container(
                  //     //     color: Colors.red,
                  //     //   );
                  //   }
                  //   // return Container(color: Colors.yellow);
                  //   return Container();
                  // }),
                  // Align(
                  //     alignment: Alignment.topCenter,
                  //     child: SizedBox(
                  //         height: 50,
                  //         child: DragTarget(builder: (BuildContext context,
                  //             List<GridDraggableData?> candidates,
                  //             List<dynamic> rejected) {
                  //           // print('top dragtarget candidates $candidates');

                  //           if (candidates.isNotEmpty) {
                  //             context.read<GridCellBloc>().add(GridCellDragged(
                  //                 dragType: GridCellDragType.top));
                  //             //   return Container(
                  //             //     color: Colors.red,
                  //             //   );
                  //           }
                  //           // return Container(color: Colors.blue);
                  //           return Container();
                  //         }, onWillAccept: (GridDraggableData? data) {
                  //           print('top dragtarget onWillAccept');
                  //           return true;
                  //         }, onAccept: (GridDraggableData? data) {
                  //           print('top dragtarget onAccept');
                  //           int? index = data?.index;
                  //           if (index != null) {
                  //             context.read<GridCellBloc>().add(GridCellDropped(
                  //                 widgetIndex: index,
                  //                 dragType: GridCellDragType.top));
                  //           }
                  //         }))),
                  // Align(
                  //     alignment: Alignment.bottomCenter,
                  //     child: SizedBox(
                  //         height: 50,
                  //         child: DragTarget(
                  //           builder: (BuildContext context,
                  //               List<GridDraggableData?> candidates,
                  //               List<dynamic> rejected) {
                  //             if (candidates.isNotEmpty) {
                  //               context.read<GridCellBloc>().add(
                  //                   GridCellDragged(
                  //                       dragType: GridCellDragType.bottom));
                  //               //   return Container(
                  //               //     color: Colors.red,
                  //               //   );
                  //             }
                  //             // return Container(color: Colors.blue);
                  //             return Container();
                  //           },
                  //           onWillAccept: (GridDraggableData? data) {
                  //             print('bottom dragtarget onWillAccept');
                  //             return true;
                  //           },
                  //           onAccept: (GridDraggableData? data) {
                  //             print('bottom dragtarget onAccept');
                  //             int? index = data?.index;
                  //             if (index != null) {
                  //               context.read<GridCellBloc>().add(
                  //                   GridCellDropped(
                  //                       widgetIndex: index,
                  //                       dragType: GridCellDragType.bottom));
                  //             }
                  //           },
                  //         ))),
                  // Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: SizedBox(
                  //         width: 50,
                  //         child: DragTarget(
                  //           builder: (BuildContext context,
                  //               List<GridDraggableData?> candidates,
                  //               List<dynamic> rejected) {
                  //             if (candidates.isNotEmpty) {
                  //               context.read<GridCellBloc>().add(
                  //                   GridCellDragged(
                  //                       dragType: GridCellDragType.left));

                  //               //   return Container(
                  //               //     color: Colors.red,
                  //               //   );
                  //             }
                  //             // return Container(color: Colors.blue);
                  //             return Container();
                  //           },
                  //           onWillAccept: (GridDraggableData? data) {
                  //             print('left dragtarget onWillAccept');
                  //             return true;
                  //           },
                  //           onAccept: (GridDraggableData? data) {
                  //             print('left dragtarget onAccept');
                  //             int? index = data?.index;
                  //             if (index != null) {
                  //               context.read<GridCellBloc>().add(
                  //                   GridCellDropped(
                  //                       widgetIndex: index,
                  //                       dragType: GridCellDragType.left));
                  //             }
                  //           },
                  //         ))),
                  // Align(
                  //     alignment: Alignment.centerRight,
                  //     child: SizedBox(
                  //         width: 50,
                  //         child: DragTarget(
                  //           builder: (BuildContext context,
                  //               List<GridDraggableData?> candidates,
                  //               List<dynamic> rejected) {
                  //             if (candidates.isNotEmpty) {
                  //               context.read<GridCellBloc>().add(
                  //                   GridCellDragged(
                  //                       dragType: GridCellDragType.right));
                  //               //   return Container(
                  //               //     color: Colors.red,
                  //               //   );
                  //             }
                  //             // return Container(color: Colors.blue);
                  //             return Container();
                  //           },
                  //           onWillAccept: (GridDraggableData? data) {
                  //             print('right dragtarget onWillAccept');
                  //             return true;
                  //           },
                  //           onAccept: (GridDraggableData? data) {
                  //             print('right dragtarget onAccept');
                  //             int? index = data?.index;
                  //             if (index != null) {
                  //               context.read<GridCellBloc>().add(
                  //                   GridCellDropped(
                  //                       widgetIndex: index,
                  //                       dragType: GridCellDragType.right));
                  //             }
                  //           },
                  //         ))),

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
              )),
            ],
          );
      }
    });
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