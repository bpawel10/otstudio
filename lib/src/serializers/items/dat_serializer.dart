import 'dart:io';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/progress_tracker.dart';

class DatSerializer extends DiskSerializer<DatDocument> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload> tracker) {
    // TODO: implement serialize
    throw UnimplementedError();
  }

  @override
  Future<DatDocument> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }
}

class DatDocument {}
