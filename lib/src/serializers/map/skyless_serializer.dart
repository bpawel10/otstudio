import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';

class SkylessSerializer extends DiskSerializer<AreaMap> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<AreaMap>> tracker) async {
    // TODO: implement serialize
  }

  @override
  Future<AreaMap> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }
}
