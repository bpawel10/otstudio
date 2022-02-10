import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WelcomeScaffold extends StatelessWidget {
  final Widget child;

  WelcomeScaffold({required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Column(children: [
        WindowTitleBarBox(
          child: MoveWindow(),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: child,
        ))
      ]));
}
