import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/progress_tracker.dart';

class Loader<T, V> extends StatefulWidget {
  final Future<V> Function(ProgressTracker<T?>) future;
  final T? payload;
  final String? label;
  final Future<void> Function(V) callback;
  final ReceivePort port = ReceivePort();

  Loader(
      {required this.future, this.payload, this.label, required this.callback});

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
    widget.callback(result);
    return result;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<V>(
      future: loader,
      builder: ((BuildContext context, AsyncSnapshot<V> snapshot) {
        if (snapshot.hasData) {
          return Container();
        }
        return Container(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 120,
              height: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                child: LinearProgressIndicator(value: progress),
              )),
          if (widget.label != null)
            Column(children: [
              SizedBox(
                height: 2,
              ),
              Text(widget.label!)
            ]),
        ]));
      }));
}
