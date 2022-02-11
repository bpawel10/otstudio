import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/screens/project_configurator/sources/assets_source.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';

class ProjectSource<T extends AssetsSource, V extends Source<AreaMap>>
    extends Source<Project> {
  final T assetsSource;
  final V mapSource;

  ProjectSource({required this.assetsSource, required this.mapSource});

  @override
  Future<Project> load(ProgressTracker tracker) async {
    Assets assets = await assetsSource.load(tracker);
    AreaMap map = await mapSource.load(tracker);
    return Project(assets: assets, map: map);
  }
}