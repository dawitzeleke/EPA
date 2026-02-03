import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/data/models/office_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

abstract class OfficeRemoteDataSource {
  Future<List<OfficeModel>> fetchOffices();
}

class OfficeRemoteDatasourceImpl implements OfficeRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  OfficeRemoteDatasourceImpl({
    required this.dio,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();


  @override
  Future<List<OfficeModel>> fetchOffices() async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.get(
        ApiConstants.officesEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['data'] is List) {
          data = response.data['data'];
        } else if (response.data is Map && response.data['offices'] is List) {
          data = response.data['offices'];
        } else {
          throw Exception('Unexpected response format');
        }

        return data.map((json) => OfficeModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'Failed to load offices',
        );
      }
    } on DioException catch (e) {
      // Handle different types of Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data['message'] ?? 
                            e.response?.data['error'] ?? 
                            'Failed to load offices. Please try again.';
        
        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 404) {
          throw Exception('Offices endpoint not found.');
        } else {
          throw Exception(errorMessage);
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to fetch offices: ${e.toString()}');
    }
  }

}