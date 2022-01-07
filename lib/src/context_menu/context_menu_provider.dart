import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'context_menu_bloc.dart';
import 'context_menu.dart';
import 'test_context_menu.dart';

class ContextMenuProvider extends StatelessWidget {
  final Widget child;

  ContextMenuProvider({required this.child});

  @override
  Widget build(BuildContext context) => BlocProvider<ContextMenuBloc>(
      create: (BuildContext context) => ContextMenuBloc(),
      child: Builder(
          builder: (BuildContext context) => GestureDetector(
              onTap: () {
                print('onTap');
                context.read<ContextMenuBloc>().add(ContextMenuClosed());
              },
              onSecondaryTapDown: (TapDownDetails details) {
                print('onSecondaryTapDown offset ${details.globalPosition}');
                context.read<ContextMenuBloc>().add(ContextMenuOpened(
                    offset: details.globalPosition, menu: TestContextMenu()));
              },
              child: Container(
                  color: Colors.pink,
                  child: Stack(children: [
                    child,
                    menu(context),
                  ])))));

  Widget menu(BuildContext context) {
    ContextMenuState state = context.read<ContextMenuBloc>().state;
    if (state is ContextMenuOpenedState) {
      return ListView(
          children: state.menu.items.map((ContextMenuItem item) {
        if (item is ContextMenuButton) {
          if (item.handler != null) {
            if (item.icon != null) {
              return TextButton.icon(
                  onPressed: () => item.handler!(context),
                  icon: item.icon!,
                  label: Text(item.name));
            } else {
              return TextButton(
                  onPressed: () => item.handler!(context),
                  child: Text(item.name));
            }
          } else {}
        }
        if (item is ContextMenuSeparator) {
          return Divider();
        }
        return Container();
      }).toList());
    }
    return Container();
  }
}
