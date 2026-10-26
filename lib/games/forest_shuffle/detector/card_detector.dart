import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'onnx_model.dart';

/// A card half found on a photo. Coordinates are in 0..1 relative to the
/// (rotated) photo; [x] and [y] are the centre of the box.
class Detection {
  final String label;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  const Detection({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// Finds Forest Shuffle cards on a photo with the YOLO model from
/// ForestDetector (https://github.com/NINI1988/ForestDetector).
class CardDetector {
  static const String _modelAsset = 'assets/models/forest_shuffle_cards.onnx';
  // The labels are stored in the model metadata, which ONNX Runtime Web can't
  // read, so they are extracted into a text file (one label per line).
  static const String _labelsAsset =
      'assets/models/forest_shuffle_cards.labels.txt';
  static const int _size = 640;
  static const int _anchors = 8400;
  static const double _minConfidence = 0.5;
  static const double _maxOverlap = 0.7;

  static final CardDetector instance = CardDetector._();

  CardDetector._();

  Future<(OnnxModel, List<String>)>? _loading;

  /// Loads the model (38 MB) once. Call early to hide the wait.
  Future<void> warmUp() => _load();

  Future<(OnnxModel, List<String>)> _load() {
    return _loading ??= () async {
      try {
        final labels = (await rootBundle.loadString(_labelsAsset))
            .split('\n')
            .where((l) => l.isNotEmpty)
            .toList();
        return (await OnnxModel.load(_modelAsset), labels);
      } catch (_) {
        _loading = null; // Allow a retry, e.g. after a network error on web.
        rethrow;
      }
    }();
  }

  /// [quarterTurns] rotates the photo clockwise before detection.
  Future<List<Detection>> detect(Uint8List imageBytes,
      {int quarterTurns = 0}) async {
    final (model, labels) = await _load();
    final input = await _prepareInput(imageBytes, quarterTurns % 4);
    final data = await model.run('images', input, const [1, 3, _size, _size]);
    return _decode(data, labels);
  }

  /// Like ForestDetector, stretches the photo to 640x640 (no letterboxing)
  /// and returns planar RGB in 0..1.
  static Future<Float32List> _prepareInput(
      Uint8List bytes, int quarterTurns) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _size,
      targetHeight: _size,
    );
    final image = (await codec.getNextFrame()).image;
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    image.dispose();
    codec.dispose();

    const plane = _size * _size;
    final input = Float32List(3 * plane);
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        // Target pixel (x, y) of the image rotated clockwise.
        final (sx, sy) = switch (quarterTurns) {
          1 => (y, _size - 1 - x),
          2 => (_size - 1 - x, _size - 1 - y),
          3 => (_size - 1 - y, x),
          _ => (x, y),
        };
        final s = (sy * _size + sx) * 4;
        final t = y * _size + x;
        input[t] = rgba.getUint8(s) / 255;
        input[plane + t] = rgba.getUint8(s + 1) / 255;
        input[2 * plane + t] = rgba.getUint8(s + 2) / 255;
      }
    }
    return input;
  }

  /// Output shape is [1, 4 + classes, 8400]: box centre/size in pixels, then
  /// one score per class.
  static List<Detection> _decode(Float32List data, List<String> labels) {
    final classes = data.length ~/ _anchors - 4;
    final found = <Detection>[];
    for (var i = 0; i < _anchors; i++) {
      var best = 0;
      var bestScore = 0.0;
      for (var c = 0; c < classes; c++) {
        final score = data[(4 + c) * _anchors + i].toDouble();
        if (score > bestScore) {
          bestScore = score;
          best = c;
        }
      }
      if (bestScore < _minConfidence) continue;
      found.add(Detection(
        label: labels[best],
        confidence: bestScore,
        x: data[i] / _size,
        y: data[_anchors + i] / _size,
        width: data[2 * _anchors + i] / _size,
        height: data[3 * _anchors + i] / _size,
      ));
    }
    return nonMaxSuppression(found);
  }

  /// Keeps the most confident box of every group of boxes that overlap by
  /// more than [_maxOverlap] (any class: two labels can't share one card).
  static List<Detection> nonMaxSuppression(List<Detection> detections) {
    final remaining = [...detections]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <Detection>[];
    while (remaining.isNotEmpty) {
      final best = remaining.removeAt(0);
      kept.add(best);
      remaining.removeWhere((d) => _iou(best, d) >= _maxOverlap);
    }
    return kept;
  }

  static double _iou(Detection a, Detection b) {
    final w = _overlap(a.x, a.width, b.x, b.width);
    final h = _overlap(a.y, a.height, b.y, b.height);
    final inter = w * h;
    if (inter <= 0) return 0;
    return inter / (a.width * a.height + b.width * b.height - inter);
  }

  static double _overlap(double c1, double s1, double c2, double s2) {
    final lo = (c1 - s1 / 2) > (c2 - s2 / 2) ? c1 - s1 / 2 : c2 - s2 / 2;
    final hi = (c1 + s1 / 2) < (c2 + s2 / 2) ? c1 + s1 / 2 : c2 + s2 / 2;
    return hi > lo ? hi - lo : 0;
  }
}
