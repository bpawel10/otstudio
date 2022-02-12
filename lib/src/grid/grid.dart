import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/grid/grid_tree.dart';

class Grid extends StatelessWidget {
  final GridTree tree;

  Grid({required this.tree});

  @override
  Widget build(BuildContext context) {
    print('Grid.build');
    return BlocProvider<GridBloc>(
        create: (BuildContext context) => GridBloc(
              GridState(tree: tree),
            ),
        child: GridCell([]));
  }
}

// class Grid extends StatelessWidget {
//   final GridConfig config;

//   Grid(this.config);

//   aa(dynamic listTree) {
//     if (listTree is Widget) {
//       return Leaf(value: listTree);
//     }
//     if (listTree is List) {
//       return listTree.map((e) => aa(e));
//     }
//   }

//   @override
//   Widget build(BuildContext context) => BlocProvider<GridBloc>(
//       create: (BuildContext context) {
//         return GridBloc(GridState(
//             tree: GridTree(Composite(
//           type: GridCellType.row,
//           children: [
//             Composite(
//                 type: GridCellType.cell,
//                 children: [Leaf(value: Container()), Leaf(value: Container())]),
//             Composite(
//                 type: GridCellType.cell, children: [Leaf(value: Container())]),
//           ],
//         ))));
//       },
//       child: GridCell([]));
// }



// class Grid extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     print('grid build');
//     return BlocProvider<GridBloc>(
//         create: (BuildContext context) {
//           return GridBloc(GridState(
//               tree: GridTree(Composite(
//             type: GridCellType.row,
//             children: [
//               Composite(type: GridCellType.cell, children: [
//                 Leaf(value: Container()),
//                 Leaf(value: Container())
//               ]),
//               Composite(
//                   type: GridCellType.cell,
//                   children: [Leaf(value: Container())]),
//             ],
//           ))));
//         },
//         child: GridCell([]));
//   }
// }
