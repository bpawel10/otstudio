abstract class _Node {
  int id;
  int parentId;

  _Node({required this.id, required this.parentId});
}

class _Composite<T> extends _Node {
  T type;
  List<_Node> children;

  _Composite(
      {required int id,
      required int parentId,
      required this.type,
      required this.children})
      : super(id: id, parentId: parentId);
}

class _Leaf<T> extends _Node {
  List<T> values;

  _Leaf({required int id, required int parentId, required this.values})
      : super(id: id, parentId: parentId);
}

class Tree<T, V> {
  Map<int, _Node> _nodes = Map();
  // _Node _root = _Leaf

  remove(_Node node) {
    _Node parent = _nodes[node.parentId]!;
    if (node is _Composite) {
      List<_Node> children = node.children;
    }
  }
}
