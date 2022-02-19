import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/models/position.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/serializers/map/skyless_serializer.dart';
import 'package:otstudio/src/models/item.dart';

abstract class ProjectEvent {}

class SelectItemProjectEvent extends ProjectEvent {
  final int id;

  SelectItemProjectEvent({required this.id});
}

class AddItemToMapProjectEvent extends ProjectEvent {
  final int id;
  final Position position;

  AddItemToMapProjectEvent({required this.id, required this.position});
}

class SaveProjectEvent extends ProjectEvent {}

class ProjectState {
  Project project;

  ProjectState({required this.project});
}

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(ProjectState initialState) : super(initialState) {
    on<SelectItemProjectEvent>((event, emit) => emit(ProjectState(
        project: Project(
            path: state.project.path,
            assets: state.project.assets,
            map: state.project.map..selectedItemId = event.id))));
    on<AddItemToMapProjectEvent>((event, emit) {
      Item item = state.project.assets.items.items[event.id]!;
      emit(ProjectState(
          project: Project(
              path: state.project.path,
              assets: state.project.assets,
              map: state.project.map..map.addItem(event.position, item))));
    });
    on<SaveProjectEvent>((event, emit) async {
      emit(ProjectState(
          project: Project(
              path: state.project.path,
              saving: 0,
              assets: state.project.assets,
              map: state.project.map)));
      await Future.delayed(Duration(seconds: 1));
      ReceivePort receivePort = ReceivePort();
      receivePort.listen((message) => emit(ProjectState(
          project: Project(
              path: state.project.path,
              saving: message,
              assets: state.project.assets,
              map: state.project.map))));
      await compute(
          SkylessSerializer().serialize,
          ProgressTracker(
              DiskSerializerSerializePayload(
                  data: state.project.map.map, path: state.project.path),
              receivePort.sendPort));
      emit(ProjectState(
          project: Project(
              path: state.project.path,
              saving: null,
              assets: state.project.assets,
              map: state.project.map)));
    });
  }
}
