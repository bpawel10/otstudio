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
      child: BlocBuilder<ContextMenuBloc, ContextMenuState>(
          builder: (BuildContext context, ContextMenuState state) =>
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    print('onTap');
                    context.read<ContextMenuBloc>().add(ContextMenuClosed());
                  },
                  onSecondaryTapDown: (TapDownDetails details) {
                    print(
                        'onSecondaryTapDown offset ${details.globalPosition}');
                    context.read<ContextMenuBloc>().add(ContextMenuOpened(
                        offset: details.globalPosition,
                        menu: TestContextMenu()));
                  },
                  child: Stack(children: [
                    child,
                    menu(context, state),
                  ]))));

  Widget menu(BuildContext context, ContextMenuState state) {
    // ContextMenuState state = context.read<ContextMenuBloc>().state;
    print('menu state $state');
    if (state is ContextMenuOpenedState) {
      print('items ${state.menu.items}');
      return Positioned(
          left: state.offset.dx,
          top: state.offset.dy,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                  children: state.menu.items.map((ContextMenuItem item) {
                if (item is TestContextMenuButton) {
                  print('item is TestContextMenuButton');
                }
                if (item is ContextMenuButton) {
                  print('item is ContextMenuButton');
                  if (item.handler != null) {
                    if (item.icon != null) {
                      print('tb.icon');
                      return TextButton.icon(
                          onPressed: () => item.handler!(context),
                          icon: item.icon!,
                          label: Text(item.name));
                    } else {
                      print('tb');
                      return TextButton(
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(
                                  Colors.grey.shade700)),
                          onPressed: () => item.handler!(context),
                          child: Text(item.name));
                    }
                  } else {}
                }
                if (item is ContextMenuSeparator) {
                  return Divider();
                }
                return Container();
              }).toList())));
    }
    return Container();
  }
}
