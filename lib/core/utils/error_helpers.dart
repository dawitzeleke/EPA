import 'package:dio/dio.dart';

/// Shared error-message helpers.
///
/// Previously duplicated in [ReportController] and [ReportOtpController].
class ErrorHelpers {
  ErrorHelpers._();

  /// Returns a user-friendly error message from any [error] object.
  static String cleanErrorMessage(Object error) {
    if (error is DioException) {
      final extracted = extractMessage(error.response?.data);
      if (extracted != null && extracted.trim().isNotEmpty) {
        return extracted.trim();
      }
      final msg = error.message;
      if (msg != null && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }
    final text = error.toString();
    final cleaned = text
        .replaceAll('Exception: ', '')
        .replaceAll(RegExp(r'^DioException[^:]*:\s*'), '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }

  /// Tries to pull a human-readable message out of an API response body.
  static String? extractMessage(dynamic data) {
    if (data is Map) {
      for (final key in ['message', 'msg', 'detail', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return null;
  }
}
