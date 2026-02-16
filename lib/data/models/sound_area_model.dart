/// Data model for sound areas
class SoundAreaModel {
  final String id;
  final String name;
  final String description;
  final double? standardNoiselevelDay;
  final double? standardNoiselevelNight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  SoundAreaModel({
    required this.id,
    required this.name,
    required this.description,
    this.standardNoiselevelDay,
    this.standardNoiselevelNight,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory SoundAreaModel.fromJson(Map<String, dynamic> json) {
    return SoundAreaModel(
      id: json['sound_area_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      standardNoiselevelDay: _parseDouble(json['standard_noiselevel_day']),
      standardNoiselevelNight: _parseDouble(json['standard_noiselevel_night']),
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

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}


