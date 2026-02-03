/// Data model for awareness items
class AwarenessModel {
  final String awarenessId;
  final String title;
  final String awarenessDescription;
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  AwarenessModel({
    required this.awarenessId,
    required this.title,
    required this.awarenessDescription,
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Create from JSON
  factory AwarenessModel.fromJson(Map<String, dynamic> json) {
    return AwarenessModel(
      awarenessId: json['awareness_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      awarenessDescription: json['awareness_description']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'awareness_id': awarenessId,
      'title': title,
      'awareness_description': awarenessDescription,
      'file_path': filePath,
      'file_name': fileName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  /// Get full image URL from file path
  String getImageUrl(String baseUrl) {
    if (filePath.trim().isEmpty) return '';
    final rawPath = filePath.trim();

    // If API returns a full URL, use it directly
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }

    // Normalize Windows-style path separators and redundant slashes
    var urlPath = rawPath.replaceAll('\\', '/').replaceAll('//', '/');
    // Remove leading slash to avoid // in final URL
    if (urlPath.startsWith('/')) {
      urlPath = urlPath.substring(1);
    }

    // Encode path segments to handle spaces/special characters
    final encodedPath = urlPath
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');

    // Build final URL robustly
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return '$normalizedBase$encodedPath';
  }
}

