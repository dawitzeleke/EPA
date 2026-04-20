import 'dart:math';
import 'package:dio/dio.dart';
import 'package:eprs/core/utils/secure_log.dart';

/// Dio interceptor that retries failed requests with **exponential back-off**.
///
/// Only retransmits on:
///   • Connection timeouts / receive timeouts / send timeouts
///   • HTTP 5xx server errors
///   • Connection errors (no internet, DNS failure, etc.)
///
/// Safe methods (GET, HEAD, OPTIONS) are always retried.
/// Unsafe methods (POST, PUT, PATCH, DELETE) are retried only when
/// [retryUnsafeMethods] is `true` (default: `false`).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.retryUnsafeMethods = false,
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final bool retryUnsafeMethods;

  /// Track retry count per request via `extra`.
  static const _retryCountKey = '__retryCount';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final int attempt = (options.extra[_retryCountKey] as int?) ?? 0;

    if (attempt >= maxRetries || !_shouldRetry(err)) {
      return handler.next(err);
    }

    // Don't retry unsafe methods unless explicitly allowed
    final method = options.method.toUpperCase();
    final isSafe = ['GET', 'HEAD', 'OPTIONS'].contains(method);
    if (!isSafe && !retryUnsafeMethods) {
      return handler.next(err);
    }

    final delay = baseDelay * pow(2, attempt);
    secureLog(
      '🔄 Retry ${attempt + 1}/$maxRetries for ${options.method} ${options.path} '
      'after ${delay.inMilliseconds}ms',
    );

    await Future.delayed(delay);

    options.extra[_retryCountKey] = attempt + 1;

    try {
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        return statusCode >= 500;
      default:
        return false;
    }
  }
}
