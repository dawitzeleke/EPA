import 'package:dio/dio.dart';
import 'package:eprs/core/utils/secure_log.dart';

/// Simple in-memory cache entry.
class _CacheEntry {
  _CacheEntry(this.response, this.timestamp);

  final Response response;
  final DateTime timestamp;

  bool isExpired(Duration ttl) =>
      DateTime.now().difference(timestamp) > ttl;
}

/// Dio interceptor that caches **GET** responses in memory.
///
/// Cached responses are served when:
///   1. The same URL+queryParams are requested within [ttl], OR
///   2. The network request fails and a stale cached copy exists
///      (stale-while-revalidate pattern).
///
/// Only GET requests are cached. Non-GET requests invalidate any
/// cached entry for the same path.
class CacheInterceptor extends Interceptor {
  CacheInterceptor({
    this.ttl = const Duration(minutes: 5),
    this.maxEntries = 50,
  });

  final Duration ttl;
  final int maxEntries;
  final Map<String, _CacheEntry> _cache = {};

  /// Number of currently cached entries (useful for testing / metrics).
  int get cacheSize => _cache.length;

  /// Clear the entire cache.
  void clear() => _cache.clear();

  /// Invalidate a specific cache key.
  void invalidate(String key) => _cache.remove(key);

  String _cacheKey(RequestOptions options) {
    // Include query parameters so /items?page=1 ≠ /items?page=2
    final uri = options.uri;
    return '${options.method}:$uri';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      // Non-GET request: invalidate any cached copy of this resource
      final key = 'GET:${options.uri}';
      _cache.remove(key);
      return handler.next(options);
    }

    final key = _cacheKey(options);
    final entry = _cache[key];

    if (entry != null && !entry.isExpired(ttl)) {
      secureLog('📦 Cache HIT for ${options.path}');
      // Return cached response immediately
      return handler.resolve(entry.response);
    }

    // Cache miss → continue with network request
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET responses
    if (response.requestOptions.method.toUpperCase() == 'GET') {
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        final key = _cacheKey(response.requestOptions);
        _cache[key] = _CacheEntry(response, DateTime.now());

        // Evict oldest entries if over limit
        if (_cache.length > maxEntries) {
          _evictOldest();
        }

        secureLog('📦 Cached response for ${response.requestOptions.path}');
      }
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // On network failure, return stale cached response if available
    if (err.requestOptions.method.toUpperCase() == 'GET') {
      final key = _cacheKey(err.requestOptions);
      final entry = _cache[key];
      if (entry != null) {
        secureLog(
          '📦 Serving STALE cache for ${err.requestOptions.path} (network error)',
        );
        return handler.resolve(entry.response);
      }
    }
    return handler.next(err);
  }

  void _evictOldest() {
    if (_cache.isEmpty) return;
    // Find the oldest entry
    String? oldestKey;
    DateTime? oldestTime;
    for (final entry in _cache.entries) {
      if (oldestTime == null ||
          entry.value.timestamp.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.timestamp;
      }
    }
    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }
}
