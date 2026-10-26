import 'dart:convert';
import 'dart:io';

import 'package:odin_score_keeper/games/forest_shuffle/engine/forest_shuffle_engine.dart';

const fixtureDir = 'test/forest_shuffle/fixtures';

dynamic loadJson(String name) =>
    jsonDecode(File('$fixtureDir/$name').readAsStringSync());

List<Prediction> loadPredictions(String name) =>
    Prediction.listFromJson(loadJson(name) as Map<String, dynamic>);
