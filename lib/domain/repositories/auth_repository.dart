import '../entities/login_entity.dart';
import '../entities/signup_entity.dart';
import '../entities/update_profile_entity.dart';

/// Repository interface for authentication operations
/// This is part of the domain layer and defines the contract
abstract class AuthRepository {
  /// Login with email and password
  /// Returns LoginResponseEntity on success
  /// Throws exception on failure
  Future<LoginResponseEntity> login(LoginEntity loginEntity);
  
  /// Signup with full name, email and password
  /// Returns SignupResponseEntity on success
  /// Throws exception on failure
  Future<SignupResponseEntity> signup(SignupEntity signupEntity);
  
  /// Verify OTP for signup
  /// Returns OtpVerificationResponseEntity on success
  /// Throws exception on failure
  Future<OtpVerificationResponseEntity> verifyOtp(OtpVerificationEntity otpEntity);
  
  /// Resend OTP
  /// Returns success status
  /// Throws exception on failure
  Future<bool> resendOtp(String email);
  
  /// Logout current user
  Future<void> logout();
  
  /// Check if user is logged in
  Future<bool> isLoggedIn();
  
  /// Get current user token
  Future<String?> getToken();

  /// Update profile (e.g., full name)
  Future<UpdateProfileResponseEntity> updateProfile(
    UpdateProfileEntity updateProfileEntity,
  );
}

