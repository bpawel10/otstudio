import 'dart:ui' as ui;

class Atlas {
  final ui.Image atlas;
  final Map<int, ui.Rect> rects;
  final double scale;

  Atlas({required this.atlas, required this.rects, this.scale = 1});
}
