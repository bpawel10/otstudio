import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/sources/source.dart';

class OtbmSource extends Source<AreaMap> {
  final String? otbmPath;

  OtbmSource({this.otbmPath});

  @override
  Future<AreaMap> load() {
    // TODO: implement load
    throw UnimplementedError();
  }
}
