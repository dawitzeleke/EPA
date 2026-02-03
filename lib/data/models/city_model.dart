/// Data model for cities
class CityModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  CityModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['city_id']?.toString() ?? '',
      name: json['city_name']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

