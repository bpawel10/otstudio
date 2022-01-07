import 'package:flutter/material.dart';
import 'package:otstudio/src/context_menu/context_menu.dart';

class TestContextMenuButton extends ContextMenuButton {
  Image? get icon => null;
  String get name => 'Test';
  Function(BuildContext)? get handler => null;
  List<ContextMenuItem>? get items => null;
}

class TestContextMenu extends ContextMenu {
  List<ContextMenuItem> get items {
    return [
      TestContextMenuButton(),
      TestContextMenuButton(),
      TestContextMenuButton(),
    ];
  }
}
