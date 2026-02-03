import '../../domain/entities/login_entity.dart';
import '../../domain/entities/signup_entity.dart';
import '../../domain/entities/update_profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/login_model.dart';
import '../models/signup_model.dart';
import '../models/update_profile_model.dart';

/// Implementation of AuthRepository
/// This connects the domain layer with the data layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<LoginResponseEntity> login(LoginEntity loginEntity) async {
    try {
      // Convert entity to model
      final loginModel = LoginModel(
        email: loginEntity.email,
        password: loginEntity.password,
        username: loginEntity.username,
      );

      // Call remote data source
      final response = await remoteDataSource.login(loginModel);

      // Save to local storage if login is successful
      if (response.success && response.token != null) {
        await localDataSource.saveToken(response.token!);
        if (response.userId != null) {
          await localDataSource.saveUserId(response.userId!);
        }
        if (response.username != null) {
          await localDataSource.saveUsername(response.username!);
        }
        if (response.phoneNumber != null) {
          await localDataSource.savePhoneNumber(response.phoneNumber!);
        }
      }

      // Convert model to entity and return
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear local storage
      await localDataSource.clearAll();
    } catch (e) {
      // Even if clearing fails, we should continue
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<SignupResponseEntity> signup(SignupEntity signupEntity) async {
    try {
      // Convert entity to model
      final signupModel = SignupModel(
        fullName: signupEntity.fullName,
        email: signupEntity.email,
        phoneNumber: signupEntity.phoneNumber,
        password: signupEntity.password,
        confirmPassword: signupEntity.confirmPassword,
      );

      // Call remote data source
      final response = await remoteDataSource.signup(signupModel);

      // Convert model to entity and return
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OtpVerificationResponseEntity> verifyOtp(OtpVerificationEntity otpEntity) async {
    try {
      // Convert entity to model
      final otpModel = OtpVerificationModel(
        email: otpEntity.email,
        otp: otpEntity.otp,
      );

      // Call remote data source
      final response = await remoteDataSource.verifyOtp(otpModel);

      // Save to local storage if verification is successful (if we get here without exception, it's successful)
      if (response.token != null) {
        await localDataSource.saveToken(response.token!);
      }
      if (response.userId != null) {
        await localDataSource.saveUserId(response.userId!);
      }
      if (response.username != null) {
        await localDataSource.saveUsername(response.username!);
      }

      // Convert model to entity and return
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> resendOtp(String email) async {
    try {
      return await remoteDataSource.resendOtp(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UpdateProfileResponseEntity> updateProfile(
    UpdateProfileEntity updateProfileEntity,
  ) async {
    try {
      final updateModel = UpdateProfileModel(
        id: updateProfileEntity.id,
        fullName: updateProfileEntity.fullName,
        currentPassword: updateProfileEntity.currentPassword,
        newPassword: updateProfileEntity.newPassword,
        confirmPassword: updateProfileEntity.confirmPassword,
      );

      final response = await remoteDataSource.updateProfile(updateModel);

      // Persist updated name locally for quick access
      if (response.fullName != null && response.fullName!.isNotEmpty) {
        await localDataSource.saveUsername(response.fullName!);
      } else {
        await localDataSource.saveUsername(updateProfileEntity.fullName);
      }

      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}

