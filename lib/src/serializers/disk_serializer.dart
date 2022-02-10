import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/serializer.dart';

abstract class DiskSerializer<T> extends Serializer<
    DiskSerializerSerializePayload<T>, DiskSerializerDeserializePayload, T> {
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<T>> tracker);
  Future<T> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker);
}

class DiskSerializerSerializePayload<T> {
  final T data;
  final String path;

  DiskSerializerSerializePayload({required this.data, required this.path});
}

class DiskSerializerDeserializePayload {
  final String path;

  DiskSerializerDeserializePayload(this.path);
}
