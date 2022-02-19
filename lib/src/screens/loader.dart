import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/utils/loading_indicator.dart';

class Loader<T, V> extends StatefulWidget {
  final Future<V> Function(ProgressTracker<T?>) future;
  final T? payload;
  final Widget? label;
  final Widget? details;
  final Future<void> Function(V) callback;
  final ReceivePort port = ReceivePort();

  Loader(
      {required this.future,
      this.payload,
      this.label,
      this.details,
      required this.callback});

  @override
  _State<T, V> createState() => _State<T, V>();
}

class _State<T, V> extends State<Loader<T, V>> {
  double progress = 0;
  late Future<V> loader;

  initState() {
    super.initState();
    loader = load();
  }

  Future<V> load() async {
    ProgressTracker<T?> tracker =
        ProgressTracker<T?>(widget.payload, widget.port.sendPort);
    widget.port.listen((newProgress) => setState(() => progress = newProgress));
    V result = await compute(widget.future, tracker);
    await widget.callback(result);
    return result;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<V>(
      future: loader,
      builder: ((BuildContext context, AsyncSnapshot<V> snapshot) {
        if (snapshot.hasData) {
          return Container();
        }
        return LoadingIndicator(
          progress: progress,
          label: widget.label,
          details: widget.details,
        );
      }));
}
