import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/map.dart' as modelMap;

class Project {
  final Assets assets;
  final modelMap.Map map;

  Project({required this.assets, required this.map});
}
