import 'dart:isolate';

class ProgressTracker<T> {
  final T data;
  SendPort _sendPort;

  ProgressTracker(this.data, this._sendPort);

  set progress(double progress) {
    _sendPort.send(progress);
  }
}
