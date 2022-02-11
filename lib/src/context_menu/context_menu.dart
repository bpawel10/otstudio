import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ContextMenu {
  List<ContextMenuItem> get items;
}

abstract class ContextMenuItem {}

abstract class ContextMenuButton extends ContextMenuItem {
  Image? get icon;
  String get name;
  Function(BuildContext context)? get handler;
  List<ContextMenuItem>? items;
}

abstract class ContextMenuSeparator extends ContextMenuItem {}
