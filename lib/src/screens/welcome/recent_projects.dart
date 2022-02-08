import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/app_bloc.dart';
import 'package:otstudio/src/screens/welcome/recent_project.dart';

class RecentProjects extends StatelessWidget {
  RecentProjects();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppBloc, AppState>(builder: ((context, state) {
        if (state.recentProjects == null) {
          return Center(child: Text('Loading'));
        }
        if (state.recentProjects!.isEmpty) {
          return Center(child: Text('Nothing'));
        }
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.recentProjects!
                  .map((path) => RecentProject(path: path))
                  .toList()),
        );
      }));
}
