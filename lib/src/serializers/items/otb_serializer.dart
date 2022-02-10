import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/progress_tracker.dart';

class OtbSerializer extends DiskSerializer<OtbDocument> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<OtbDocument>> tracker) {
    // TODO: implement serialize
    throw UnimplementedError();
  }

  @override
  Future<OtbDocument> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }
}

class OtbDocument {}
