import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/data/models/awareness_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

abstract class AwarenessRemoteDataSource {
  Future<List<AwarenessModel>> fetchAwareness();
}

class AwarenessRemoteDataSourceImpl implements AwarenessRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  AwarenessRemoteDataSourceImpl({
    required this.dio,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();

  @override
  Future<List<AwarenessModel>> fetchAwareness() async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.get(
        ApiConstants.awarenessEndpoint,
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
        } else if (response.data is Map && response.data['awareness'] is List) {
          data = response.data['awareness'];
        } else {
          throw Exception('Unexpected response format');
        }

        return data.map((json) => AwarenessModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'Failed to load awareness items',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 
          e.response?.data['error'] ?? 
          'Failed to load awareness items',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load awareness items: $e');
    }
  }
}

