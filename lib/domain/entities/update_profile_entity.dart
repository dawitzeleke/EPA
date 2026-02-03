/// Domain entity representing an update profile request
class UpdateProfileEntity {
  final String id;
  final String fullName;
  final String? currentPassword;
  final String? newPassword;
  final String? confirmPassword;

  UpdateProfileEntity({
    required this.id,
    required this.fullName,
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  });
}

/// Domain entity representing an update profile response
class UpdateProfileResponseEntity {
  final bool success;
  final String? message;
  final String? fullName;

  UpdateProfileResponseEntity({
    required this.success,
    this.message,
    this.fullName,
  });
}
