import 'dart:ui' as ui;

class Atlas {
  final ui.Image atlas;
  final Map<int, ui.Rect> rects;

  Atlas({required this.atlas, required this.rects});
}
