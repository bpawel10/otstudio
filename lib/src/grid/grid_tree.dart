import 'package:otstudio/src/grid/grid_cell_drag_targets.dart';
import 'package:otstudio/src/grid/tree.dart';
import 'package:collection/collection.dart';

enum GridCellType { column, row, cell }

class GridTree extends Tree<GridCellType, Type> {
  GridTree(Node node) : super(node);
  GridTree.from(GridTree gridTree) : super.from(gridTree);

  void add(List<int> path, Type value) {
    getNode(path).children.add(Leaf<Type>(value: value));
  }

  void splitLeft(List<int> source, List<int> target) {
    Node sourceNode = removeNode(source);
    Node targetNode = getNode(target);
    Node targetParentNode = getNode(List.from(target)..removeLast());
    Node sourceNodeToMove =
        Composite(type: GridCellType.cell, children: [sourceNode]);
    if (targetParentNode is Composite<GridCellType> &&
        targetParentNode.type == GridCellType.row) {
      targetParentNode.children.insert(0, sourceNodeToMove);
    } else {
      Node row = Composite<GridCellType>(
          type: GridCellType.row, children: [sourceNodeToMove, targetNode]);
      targetParentNode.children[target[target.length - 1]] = row;
    }
  }

  void splitRight(List<int> source, List<int> target) {
    Node sourceNode = removeNode(source);
    Node targetNode = getNode(target);
    Node targetParentNode = getNode(List.from(target)..removeLast());

    Node sourceNodeToMove =
        Composite(type: GridCellType.cell, children: [sourceNode]);
    if (targetParentNode is Composite<GridCellType> &&
        targetParentNode.type == GridCellType.row) {
      targetParentNode.children.add(sourceNodeToMove);
    } else {
      Node row = Composite<GridCellType>(
          type: GridCellType.row, children: [targetNode, sourceNodeToMove]);
      targetParentNode.children[target[target.length - 1]] = row;
    }
  }

  void splitTop(List<int> source, List<int> target) {
    Node sourceNode = removeNode(source);
    Node targetNode = getNode(target);
    Node targetParentNode = getNode(List.from(target)..removeLast());
    Node sourceNodeToMove =
        Composite(type: GridCellType.cell, children: [sourceNode]);
    if (targetParentNode is Composite<GridCellType> &&
        targetParentNode.type == GridCellType.column) {
      targetParentNode.children.insert(0, sourceNodeToMove);
    } else {
      Node column = Composite<GridCellType>(
          type: GridCellType.column, children: [sourceNodeToMove, targetNode]);
      targetParentNode.children[target[target.length - 1]] = column;
    }
  }

  void splitBottom(List<int> source, List<int> target) {
    Node sourceNode = removeNode(source);
    Node targetNode = getNode(target);
    Node targetParentNode = getNode(List.from(target)..removeLast());

    Node sourceNodeToMove =
        Composite(type: GridCellType.cell, children: [sourceNode]);
    if (targetParentNode is Composite<GridCellType> &&
        targetParentNode.type == GridCellType.column) {
      targetParentNode.children.add(sourceNodeToMove);
    } else {
      Node column = Composite<GridCellType>(
          type: GridCellType.column, children: [targetNode, sourceNodeToMove]);
      targetParentNode.children[target[target.length - 1]] = column;
    }
  }

  void move(List<int> source, List<int> target) {
    Leaf<Type> sourceNode = removeNode(source) as Leaf<Type>;
    add(target, sourceNode.value);
  }

  void removeEmptyForOne(List<int> path) {
    Node cellNode = getNode(path);
    print(
        'removeEmptyForOne path $path cellNode $cellNode children ${cellNode.children}');
    if (cellNode is Composite<GridCellType> && cellNode.children.isEmpty) {
      int emptyNodeIndex = path.removeLast();
      Node cellParentNode = getNode(path);
      cellParentNode.children.removeAt(emptyNodeIndex);
    }
  }

  void removeEmptyForAll(List<int> path) {
    Node cellNode = getNode(path);
    removeEmptyForOne(path);
    if (cellNode is Composite<GridCellType> && cellNode.children.isNotEmpty) {
      cellNode.children.forEachIndexed((int index, Node _) {
        removeEmptyForAll([...path, index]);
      });
    }
  }
}
