import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double progress;
  final Widget? label;
  final Widget? details;

  LoadingIndicator({this.progress = 0, this.label, this.details});

  @override
  Widget build(BuildContext context) => Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 120,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              child: LinearProgressIndicator(value: progress),
            )),
        if (label != null)
          Column(children: [
            SizedBox(
              height: 4,
            ),
            label!,
            if (details != null)
              Column(
                children: [
                  SizedBox(height: 10),
                  Opacity(opacity: 0.5, child: details!),
                ],
              )
          ]),
      ]));
}
