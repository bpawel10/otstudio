import 'package:flutter/material.dart';
import 'package:otstudio/src/utils/loading_indicator.dart';

class Dialog extends StatelessWidget {
  final double? progress;
  final Widget? label;
  final Widget? details;

  Dialog({this.progress, this.label, this.details});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
            child: SizedBox(
                width: 240,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: EdgeInsets.all(10),
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (label != null) label!,
                      if (progress != null)
                        LoadingIndicator(
                          progress: progress!,
                        ),
                      if (details != null)
                        Opacity(opacity: 0.5, child: details!),
                    ],
                  )),
                ))),
      );
}
