import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/data/models/sound_area_model.dart';

abstract class SoundAreaRemoteDataSource {
  Future<List<SoundAreaModel>> fetchSoundAreas();
}

class SoundAreaRemoteDataSourceImpl implements SoundAreaRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  SoundAreaRemoteDataSourceImpl({
    required this.dio,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();

  @override
  Future<List<SoundAreaModel>> fetchSoundAreas() async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.get(
        ApiConstants.soundAreasEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['data'] is List) {
          data = response.data['data'];
        } else {
          throw Exception('Unexpected response format');
        }
        return data.map((e) => SoundAreaModel.fromJson(e)).toList();
      } else {
        throw Exception(
          response.data['message'] ??
              response.data['error'] ??
              'Failed to load sound areas',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          e.response?.data['message'] ??
              e.response?.data['error'] ??
              'Failed to load sound areas',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load sound areas: $e');
    }
  }
}


