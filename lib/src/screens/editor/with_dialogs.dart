import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/widgets/dialog.dart' as d;

class WithDialogs extends StatelessWidget {
  final Widget child;

  WithDialogs({required this.child});

  @override
  Widget build(BuildContext context) => BlocBuilder<ProjectBloc, ProjectState>(
      builder: (BuildContext context, ProjectState state) => Stack(children: [
            child,
            if (state.project.saving != null)
              d.Dialog(
                  progress: state.project.saving,
                  label: Text('Saving'),
                  details: Text(
                    'It can take a few minutes.\nThe app can freeze for a minute.',
                    textAlign: TextAlign.center,
                  )),
          ]));
}
