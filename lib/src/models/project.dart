import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/map.dart' as modelMap;

class Project {
  final String
      path; // TODO: make it optional and if is null ask user for path when saving for the first time
  final double? saving;
  final Assets assets;
  final modelMap.Map map;

  Project(
      {required this.path,
      this.saving,
      required this.assets,
      required this.map});
}
