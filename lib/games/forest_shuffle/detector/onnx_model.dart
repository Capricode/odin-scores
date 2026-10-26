// Runs the detector model: ONNX Runtime Web called directly on the web,
// flutter_onnxruntime everywhere else.
export 'onnx_model_io.dart' if (dart.library.js_interop) 'onnx_model_web.dart';
