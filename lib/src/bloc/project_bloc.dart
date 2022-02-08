import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/models/assets.dart';

abstract class ProjectEvent {}

abstract class ProjectState {
  String path;
  Assets assets;

  ProjectState({required this.path, required this.assets});
}

abstract class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(ProjectState initialState) : super(initialState);
}
