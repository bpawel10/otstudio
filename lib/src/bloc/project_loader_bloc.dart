import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/sources/assets_source.dart';
import 'package:otstudio/src/sources/otb_xml_spr_dat_items_source.dart';
import 'package:otstudio/src/sources/otbm_map_source.dart';
import 'package:otstudio/src/sources/project_source.dart';

abstract class ProjectLoaderEvent {}

class ProjectLoaderInitEvent extends ProjectLoaderEvent {}

class ProjectLoaderFilePickedEvent extends ProjectLoaderEvent {
  final String path;

  ProjectLoaderFilePickedEvent(this.path);
}

class ProjectLoaderState {
  final ProjectSource source;

  ProjectLoaderState({required this.source});
}

class ProjectLoaderBloc extends Bloc<ProjectLoaderEvent, ProjectLoaderState> {
  ProjectLoaderBloc(ProjectLoaderState initialState) : super(initialState) {
    on<ProjectLoaderFilePickedEvent>((event, emit) => ProjectLoaderState(
        source: ProjectSource(
            assetsSource: AssetsSource(
                itemsSource: OtbXmlSprDatItemsSource(datPath: event.path)),
            mapSource: OtbmMapSource())));
  }
}
