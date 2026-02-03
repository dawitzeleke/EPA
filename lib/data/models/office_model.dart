import 'package:latlong2/latlong.dart';

class OfficeModel {
  final String id;
  final String name;
  final String description;
  final String phoneNumber;
  final String email;
  final LatLng position;

  OfficeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.email,
    required this.position,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    // Parse latitude and longitude - they come as strings from API
    double parseCoordinate(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return OfficeModel(
      id: json['epa_office_location_id']?.toString() ?? 
          json['id']?.toString() ?? 
          '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? 
                   json['phone']?.toString() ?? 
                   '',
      email: json['email']?.toString() ?? '',
      position: LatLng(
        parseCoordinate(json['latitude']),
        parseCoordinate(json['longitude']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'epa_office_location_id': id,
      'name': name,
      'description': description,
      'phone_number': phoneNumber,
      'email': email,
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
    };
  }
}