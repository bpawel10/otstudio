import 'dart:async';
import 'dart:isolate';
import 'package:otstudio/src/progress_tracker.dart';

FutureOr<V> Function(ProgressTracker<T>) _isolateEntryPoint<T, V>(
        FutureOr<V> Function(ProgressTracker<T>) entryPoint,
        SendPort exitPort) =>
    (ProgressTracker<T> tracker) async {
      FutureOr<V> result = await entryPoint(tracker);
      Isolate.exit(
        exitPort,
        result,
      );
    };

isolate<T, V>(FutureOr<V> Function(ProgressTracker<T>) entryPoint,
    ProgressTracker<T> tracker) async {
  ReceivePort exitPort = ReceivePort();
  await Isolate.spawn(
      _isolateEntryPoint(entryPoint, exitPort.sendPort), tracker);
  return exitPort.first;
}

// class _IsolatePayload<T> {
//   ProgressTracker<T> tracker;
//   SendPort exitPort;

//   _IsolatePayload({required this.tracker, required this.exitPort});
// }
