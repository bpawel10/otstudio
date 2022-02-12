import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/models/project.dart';

abstract class ProjectEvent {}

class SelectedItemProjectEvent extends ProjectEvent {
  final int id;

  SelectedItemProjectEvent({required this.id});
}

class ProjectState {
  Project project;

  ProjectState({required this.project});
}

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(ProjectState initialState) : super(initialState) {
    on<SelectedItemProjectEvent>((event, emit) => emit(ProjectState(
        project: Project(
            assets: state.project.assets,
            map: state.project.map..selectedItemId = event.id))));
  }
}
