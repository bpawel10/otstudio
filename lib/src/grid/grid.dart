import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_cell.dart';
import 'package:otstudio/src/grid/grid_tree.dart';
import 'package:otstudio/src/grid/tree.dart';
import 'package:otstudio/src/test_widget.dart';
import 'package:otstudio/src/test_widget2.dart';
import 'package:otstudio/src/test_widget3.dart';

class Grid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('grid build');
    return BlocProvider(
        create: (BuildContext context) {
          return GridBloc(GridState(
              tree: GridTree(<int, Node>{
            0: Composite(id: 0, type: GridCellType.row),
            1: Composite(id: 1, parent: 0, type: GridCellType.cell),
            2: Leaf(id: 2, parent: 1, value: TestWidget),
            3: Leaf(id: 3, parent: 1, value: TestWidget2),
            4: Composite(id: 4, parent: 0, type: GridCellType.cell),
            5: Leaf(id: 5, parent: 4, value: TestWidget3),
          })));
        },
        child: GridCell(0));
  }
}
