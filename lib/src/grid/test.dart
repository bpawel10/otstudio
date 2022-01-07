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

void main(List<String> args) {
  Composite<int> root = Composite(type: 1, children: [
    Composite(type: 1, children: [Leaf<int>(value: 20)])
  ]);

  Node firstRootChild = root.children[0];

  print('firstRootChild children length ${root.children[0].children.length}');

  firstRootChild.children.clear();

  print('firstRootChild children length 2 ${root.children[0].children.length}');
}
