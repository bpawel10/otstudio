import 'package:otstudio/src/progress_tracker.dart';

abstract class Source<T> {
  Future<T> load(ProgressTracker tracker);
}
