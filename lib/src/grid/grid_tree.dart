import 'package:otstudio/src/grid/grid_cell_drag_targets.dart';
import 'package:otstudio/src/grid/tree.dart';

enum GridCellType { column, row, cell }

class GridTree extends Tree<GridCellType, Type> {
  GridTree([Map<int, Node>? nodes]) : super(nodes);
  GridTree.from(GridTree gridTree) : super.from(gridTree);

  void move(int source, int target) {
    Node? sourceNode = removeNode(source)!;
    if (sourceNode is Leaf<Type>) {
      add(sourceNode.value, parent: target);
    }
  }

  void splitLeft(int source, int target) {
    Node sourceLeaf = removeNode(source)!;
    if (sourceLeaf is Leaf<Type>) {
      Node targetNode = removeNode(target)!;
      if (targetNode is Composite && targetNode.type == GridCellType.cell) {
        int row =
            addComposite(parent: targetNode.parent, type: GridCellType.row);
        add(
          sourceLeaf.value,
          parent: row,
        );
        addComposite(id: targetNode.id, parent: row, type: targetNode.type);
      }
    }
  }

  void splitRight(int source, int target) {
    Node sourceLeaf = removeNode(source)!;
    if (sourceLeaf is Leaf<Type>) {
      Node targetNode = removeNode(target)!;
      if (targetNode is Composite && targetNode.type == GridCellType.cell) {
        int row =
            addComposite(parent: targetNode.parent, type: GridCellType.row);

        addComposite(id: targetNode.id, parent: row, type: targetNode.type);
        add(
          sourceLeaf.value,
          parent: row,
        );
      }
    }
  }

  void splitTop(int source, int target) {
    Node sourceLeaf = removeNode(source)!;
    if (sourceLeaf is Leaf<Type>) {
      Node targetNode = removeNode(target)!;
      if (targetNode is Composite && targetNode.type == GridCellType.cell) {
        int row =
            addComposite(parent: targetNode.parent, type: GridCellType.column);
        add(
          sourceLeaf.value,
          parent: row,
        );
        addComposite(id: targetNode.id, parent: row, type: targetNode.type);
      }
    }
  }

  void splitBottom(int source, int target) {
    print('splitBottom $source $target');
    Node sourceLeaf = removeNode(source)!;
    print('sourceLeaf $sourceLeaf');
    if (sourceLeaf is Leaf<Type>) {
      Node targetNode = removeNode(target)!;
      print('targetNode $targetNode id ${targetNode.id}');
      if (targetNode is Composite && targetNode.type == GridCellType.cell) {
        print('targetNode is Composite and of type cell');
        print('ids $ids');
        int row =
            addComposite(parent: targetNode.parent, type: GridCellType.column);
        print('ids2 $ids');
        addComposite(id: targetNode.id, parent: row, type: targetNode.type);
        print('ids3 $ids');
        int targetCell = addComposite(parent: row, type: targetNode.type);
        print('ids4 $ids');
        add(
          sourceLeaf.value,
          parent: targetCell,
        );
        print('ids5 $ids');
      }
    }
  }
}
