import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

class OnnxModel {
  final OrtSession _session;

  OnnxModel._(this._session);

  static Future<OnnxModel> load(String assetKey) async =>
      OnnxModel._(await OnnxRuntime().createSessionFromAsset(assetKey));

  /// Runs the model with one float32 input and returns its first output.
  Future<Float32List> run(String inputName, Float32List input, List<int> shape) async {
    final tensor = await OrtValue.fromList(input, shape);
    try {
      final outputs = await _session.run({inputName: tensor});
      try {
        final data = await outputs.values.first.asFlattenedList();
        return data is Float32List ? data : Float32List.fromList(data.cast<double>());
      } finally {
        for (final o in outputs.values) {
          await o.dispose();
        }
      }
    } finally {
      await tensor.dispose();
    }
  }
}
