import 'dart:math';

import 'package:flutter/material.dart';

class ResizableColumn extends StatefulWidget {
  final double initialWidth;
  final double minWidth;
  final Widget child;

  const ResizableColumn(
      {required this.initialWidth, this.minWidth = 0, required this.child});

  @override
  ResizableColumnState createState() => ResizableColumnState();
}

class ResizableColumnState extends State<ResizableColumn> {
  double width = 0;

  @override
  initState() {
    super.initState();
    setState(() {
      this.width = this.widget.initialWidth;
    });
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(width: this.width, child: widget.child),
        GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                this.width =
                    max(this.width + details.delta.dx, widget.minWidth);
              });
            },
            child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: SizedBox(
                  width: 5,
                  child: Container(
                      // decoration: BoxDecoration(color: ),
                      ),
                ))),
      ]);
}
