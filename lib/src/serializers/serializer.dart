import 'package:otstudio/src/progress_tracker.dart';

abstract class Serializer<T, V, U> {
  Future<void> serialize(ProgressTracker<T> tracker);
  Future<U> deserialize(ProgressTracker<V> tracker);
}
