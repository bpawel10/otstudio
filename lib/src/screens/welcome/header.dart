import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/app_bloc.dart';

class Header extends StatelessWidget {
  Header();

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(
          'OTStudio',
          style: TextStyle(fontSize: 24),
        ),
        BlocBuilder<AppBloc, AppState>(
          builder: (BuildContext context, AppState state) =>
              Text(state.packageInfo?.version ?? ''),
        ),
      ]);
}
