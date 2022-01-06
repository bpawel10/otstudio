abstract class Node {
  int id;
  int? parent;

  Node({required this.id, this.parent});
}

class Composite<T> extends Node {
  T type;

  Composite({
    required int id,
    int? parent,
    required this.type,
  }) : super(id: id, parent: parent);
}

class Leaf<V> extends Node {
  V value;

  Leaf({required int id, required int parent, required this.value})
      : super(id: id, parent: parent);
}

class Tree<T, V> {
  Map<int, Node> _nodes;
  int _id;

  Tree([Map<int, Node>? nodes])
      : _nodes = nodes ?? Map(),
        _id = nodes?.length ?? 0;
  Tree.from(Tree<T, V> tree)
      : _nodes = tree._nodes,
        _id = tree._nodes.length;

  List<int> get ids {
    return _nodes.keys.toList();
  }

  Map<int, Node> get nodes {
    return _nodes;
  }

  int add(V value, {int? parent}) {
    Node parentNode = _get(parent);
    if (parentNode is Composite) {
      return _addLeaf(parent: parentNode.id, value: value);
    } else {
      throw UnsupportedError('Cannot add a leaf to a non-composite');
    }
  }

  int get _nextId {
    return _id++;
  }

  Node _get([int? id]) {
    return _nodes[id ?? 0]!;
  }

  Node? getNode(int? id) {
    return _nodes[id];
  }

  Composite<T>? getComposite(int? id) {
    Node? node = _nodes[id];
    return node is Composite<T> ? node : null;
  }

  Leaf<V>? getLeaf(int? id) {
    Node? node = _nodes[id];
    return node is Leaf<V> ? node : null;
  }

  List<int> getChildren(int id) {
    Map<int, Node> children = Map.from(_nodes)
      ..removeWhere((int _, Node node) => node.parent != id);
    return children.keys.toList();
  }

  int _addNode(Node node) {
    _nodes[node.id] = node;
    return node.id;
  }

  int addComposite({int? id, int? parent, required T type}) {
    return _addNode(Composite(id: id ?? _nextId, parent: parent, type: type));
  }

  int _addLeaf({required int parent, required V value}) {
    return _addNode(Leaf(id: _nextId, parent: parent, value: value));
  }

  Node? removeNode(int id) {
    Node node = _get(id);
    Node? parentNode = _nodes[node.parent];
    List<int> children = getChildren(node.id);
    children.forEach((child) {
      _nodes[child]!.parent = parentNode?.id;
    });
    return _nodes.remove(node.id);
  }
}
