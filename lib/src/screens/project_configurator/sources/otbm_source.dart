import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';

class OtbmSource extends Source<AreaMap> {
  final String? otbmPath;

  OtbmSource({this.otbmPath});

  @override
  Future<AreaMap> load(ProgressTracker tracker) {
    // TODO: implement load
    throw UnimplementedError();
  }
}
