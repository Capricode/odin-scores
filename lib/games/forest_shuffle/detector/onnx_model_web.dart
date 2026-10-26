import 'dart:js_interop';
import 'dart:typed_data';

// The flutter_onnxruntime web plugin copies tensors element by element
// through Dart lists (millions of boxed numbers for this model), which gets
// the tab killed on iPhones. These bindings hand typed arrays to ONNX Runtime
// Web (loaded in web/index.html) without copying.

@JS('ort.InferenceSession.create')
external JSPromise<_InferenceSession> _createSession(JSString url, JSAny options);

extension type _InferenceSession._(JSObject _) implements JSObject {
  external JSPromise<JSObject> run(JSObject feeds);
  external JSArray<JSString> get outputNames;
}

@JS('ort.Tensor')
extension type _Tensor._(JSObject _) implements JSObject {
  external factory _Tensor(JSString type, JSFloat32Array data, JSArray<JSNumber> dims);
  external JSFloat32Array get data;
  external void dispose();
}

extension on JSObject {
  external JSAny? operator [](JSString key);
  external void operator []=(JSString key, JSAny? value);
}

class OnnxModel {
  final _InferenceSession _session;

  OnnxModel._(this._session);

  /// Flutter web serves the asset with key `k` at `assets/k`.
  static Future<OnnxModel> load(String assetKey) async {
    final options = {
      'executionProviders': ['wasm'],
      // Lower peak memory; iOS kills tabs that use too much.
      'enableCpuMemArena': false,
      'enableMemPattern': false,
    }.jsify()!;
    return OnnxModel._(await _createSession('assets/$assetKey'.toJS, options).toDart);
  }

  /// Runs the model with one float32 input and returns its first output.
  Future<Float32List> run(String inputName, Float32List input, List<int> shape) async {
    final tensor = _Tensor('float32'.toJS, input.toJS, [for (final d in shape) d.toJS].toJS);
    final feeds = JSObject()..[inputName.toJS] = tensor;
    try {
      final outputs = await _session.run(feeds).toDart;
      final output = outputs[_session.outputNames.toDart.first]! as _Tensor;
      // Copy out of the tensor so it can be released right away.
      final data = Float32List.fromList(output.data.toDart);
      output.dispose();
      return data;
    } finally {
      tensor.dispose();
    }
  }
}
