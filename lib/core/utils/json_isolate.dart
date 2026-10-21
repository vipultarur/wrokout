import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Top-level function for compute/Isolate.run decoding JSON strings without blocking main UI thread.
List<dynamic> decodeJsonListTopLevel(String jsonString) {
  return json.decode(jsonString) as List<dynamic>;
}

/// Helper method to decode large JSON strings in a background isolate.
Future<List<dynamic>> parseJsonInIsolate(String jsonString) async {
  return compute(decodeJsonListTopLevel, jsonString);
}
