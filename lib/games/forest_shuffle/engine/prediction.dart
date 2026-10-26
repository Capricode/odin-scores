/// One detection from the card detector model.
///
/// Coordinates are the box centre and size. The assembler only compares them
/// with each other, so normalised (0..1) and pixel values both work.
class Prediction {
  final String label;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  const Prediction({
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.confidence = 1,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        label: json['class'] as String,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 1,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'class': label,
        'confidence': confidence,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  /// Parses a whole detector response (`{"predictions": [...]}`).
  static List<Prediction> listFromJson(Map<String, dynamic> json) =>
      (json['predictions'] as List)
          .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList();
}
