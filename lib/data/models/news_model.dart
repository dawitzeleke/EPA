/// Data model for awareness items
class NewsModel {
  final String newsId;
  final String title;
  final String newsDescription;
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  NewsModel({
    required this.newsId,
    required this.title,
    required this.newsDescription,
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Create from JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      newsId: json['news_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      newsDescription: json['news_description']?.toString() ?? '',
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
      'news_id': newsId,
      'title': title,
      'news_description': newsDescription,
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

    // Use absolute URL as-is
    final raw = filePath.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    // Normalize separators and strip leading slash
    var path = raw.replaceAll('\\', '/').replaceAll('//', '/');
    if (path.startsWith('/')) path = path.substring(1);

    // Remove common storage prefix if present
    const publicPrefix = 'public/';
    if (path.startsWith(publicPrefix)) {
      path = path.substring(publicPrefix.length);
    }

    // Encode each segment
    final encodedPath = path
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');

    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return '$normalizedBase$encodedPath';
  }

}

