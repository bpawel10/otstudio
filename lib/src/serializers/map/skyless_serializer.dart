import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/models/position.dart';

class SkylessSerializer extends DiskSerializer<AreaMap> {
  int serializedTiles = 0;
  int lastSerializedTiles = 0;

  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<AreaMap>> tracker) async {
    print('SkylessSerializer.serialize');
    String path = tracker.data.path;
    AreaMap map = tracker.data.data;
    String mapPath = join(path, 'map');
    await Directory(mapPath).create();
    List<Area> rootAreas =
        map.areas.where((area) => area.parent == null).toList();
    await Future.forEach(
        rootAreas, (Area area) => serializeArea(mapPath, map, area, tracker));
  }

  Future<void> serializeArea(
      String path, AreaMap map, Area area, ProgressTracker tracker) async {
    String areaPath = join(path, area.name);
    await Directory(areaPath).create();
    Map<String, dynamic> areaTilesSerializedMap = Map();
    area.tiles.forEach((Position position) {
      Map<String, dynamic> serializedTile =
          map.tiles[position.toString()]!.toJson();
      areaTilesSerializedMap.addAll(serializedTile);
      serializedTiles++;
      updateProgress(tracker, map);
    });
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String areaTilesSerialized =
        encoder.convert({'tiles': areaTilesSerializedMap});
    await File(join(areaPath, '${area.name}.area'))
        .writeAsString(areaTilesSerialized);
    List<Area> children =
        map.areas.where((a) => a.parent == area.name).toList();
    children.forEach((child) => serializeArea(areaPath, map, child, tracker));
  }

  void updateProgress(ProgressTracker tracker, AreaMap map) {
    if (serializedTiles - lastSerializedTiles >= 1000) {
      tracker.progress = serializedTiles / map.tiles.length;
      lastSerializedTiles = serializedTiles;
    }
  }

  @override
  Future<AreaMap> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }
}
