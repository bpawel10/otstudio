import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/sources/assets_source.dart';
import 'package:otstudio/src/sources/source.dart';

class ProjectSource<T extends AssetsSource, V extends Source<AreaMap>>
    extends Source<Project> {
  final T assetsSource;
  final V mapSource;

  ProjectSource({required this.assetsSource, required this.mapSource});

  @override
  Future<Project> load() async {
    Assets assets = await assetsSource.load();
    AreaMap map = await mapSource.load();
    return Project(assets: assets, map: map);
  }
}
