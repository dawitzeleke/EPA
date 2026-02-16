import 'package:flutter/foundation.dart';

void secureLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
