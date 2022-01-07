abstract class Node {
  List<Node> children;

  Node({List<Node>? children}) : this.children = children ?? [];
}

class Composite<T> extends Node {
  T type;

  Composite({
    required this.type,
    List<Node>? children,
  }) : super(children: children);
}

class Leaf<V> extends Node {
  V value;

  Leaf({required this.value}) : super();
}

class Tree<T, V> {
  Node _root;

  Tree(this._root);
  Tree.from(Tree<T, V> tree) : _root = tree._root;

  Node getNode(List<int>? path) {
    print('Tree.getNode($path)');

    if (path == null || path.isEmpty) {
      return _root;
    }

    Node node = _root;

    path.forEach((index) {
      node = node.children[index];
    });

    return node;
  }

  Node removeNode(List<int> path) {
    int last = path.removeLast();
    Node parent = getNode(path);
    return parent.children.removeAt(last);
  }

  // int add(V value, {int? parent}) {
  //   Node parentNode = _get(parent);
  //   if (parentNode is Composite) {
  //     return _addLeaf(parent: parentNode.id, value: value);
  //   } else {
  //     throw UnsupportedError('Cannot add a leaf to a non-composite');
  //   }
  // }

  // int get _nextId {
  //   return _id++;
  // }

  // Node _get([int? id]) {
  //   return _nodes[id ?? 0]!;
  // }

  // Node? getNode(int? id) {
  //   return _nodes[id];
  // }

  // Composite<T>? getComposite(int? id) {
  //   Node? node = _nodes[id];
  //   return node is Composite<T> ? node : null;
  // }

  // Leaf<V>? getLeaf(int? id) {
  //   Node? node = _nodes[id];
  //   return node is Leaf<V> ? node : null;
  // }

  // List<int> getChildren(int id) {
  //   Map<int, Node> children = Map.from(_nodes)
  //     ..removeWhere((int _, Node node) => node.parent != id);
  //   return children.keys.toList();
  // }

  // int _addNode(Node node) {
  //   _nodes[node.id] = node;
  //   return node.id;
  // }

  // int addComposite({int? id, int? parent, required T type}) {
  //   return _addNode(Composite(id: id ?? _nextId, parent: parent, type: type));
  // }

  // int _addLeaf({required int parent, required V value}) {
  //   return _addNode(Leaf(id: _nextId, parent: parent, value: value));
  // }

  // Node? removeNode(int id) {
  //   Node node = _get(id);
  //   Node? parentNode = _nodes[node.parent];
  //   List<int> children = getChildren(node.id);
  //   children.forEach((child) {
  //     _nodes[child]!.parent = parentNode?.id;
  //   });
  //   return _nodes.remove(node.id);
  // }
}
