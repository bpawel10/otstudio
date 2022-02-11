import 'package:flutter/material.dart';
import 'package:otstudio/src/screens/editor/editor.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/screens/loader.dart';
import 'package:otstudio/src/screens/welcome/welcome_scaffold.dart';

class ProjectLoader extends StatelessWidget {
  final Source<Project> projectSource;

  ProjectLoader({required this.projectSource});

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
      child: Loader<void, Project>(
          label: 'Loading project',
          future: projectSource.load,
          callback: (Project project) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Editor(
                        project: project,
                      )))));
}
