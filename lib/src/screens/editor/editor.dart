import 'package:flutter/material.dart';
import 'package:otstudio/src/grid/grid.dart';
import 'package:otstudio/src/models/project.dart';

class Editor extends StatelessWidget {
  final Project project;

  Editor({required this.project});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Grid(),
      );
}
