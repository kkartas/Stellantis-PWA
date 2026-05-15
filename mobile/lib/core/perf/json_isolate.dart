import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Threshold above which jsonDecode is dispatched to a compute() isolate.
/// 8 KB is the figure called out in the Phase 7 plan; below it the
/// isolate spawn overhead outweighs the parse cost.
const int kIsolateThresholdBytes = 8 * 1024;

/// Parses [body] into a JSON object, off the UI isolate when the payload
/// is large. Small payloads are decoded synchronously to avoid paying the
/// ~1 ms spawn overhead.
Future<Object?> parseJsonAsync(String body) {
  if (body.length <= kIsolateThresholdBytes) {
    return Future.value(jsonDecode(body));
  }
  return compute(_decode, body);
}

Object? _decode(String body) => jsonDecode(body);
