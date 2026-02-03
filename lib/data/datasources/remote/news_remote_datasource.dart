import 'package:eprs/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:eprs/data/models/news_model.dart';
import 'package:get_storage/get_storage.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> fetchNews();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  NewsRemoteDataSourceImpl({
    required this.dio,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();

  @override
  Future<List<NewsModel>> fetchNews() async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.get(
        ApiConstants.newsEndpoint,
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
        } else if (response.data is Map && response.data['news'] is List) {
          data = response.data['news'];
        } else {
          throw Exception('Unexpected response format');
        }

        return data.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'Failed to load news items',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 
          e.response?.data['error'] ?? 
          'Failed to load news items',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load news items: $e');
    }
  }
}

