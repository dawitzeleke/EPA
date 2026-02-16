import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/data/models/city_model.dart';
import 'package:eprs/core/utils/secure_log.dart';

abstract class CityRemoteDataSource {
  Future<List<CityModel>> fetchCities();
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  CityRemoteDataSourceImpl({
    required this.dio,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();

  @override
  Future<List<CityModel>> fetchCities() async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.get(
        ApiConstants.citiesEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      secureLog('Cities API Response: ${response.data}');
      secureLog('Cities API Response Status Code: ${response.statusCode}');
      secureLog('Cities API Response Type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          data = response.data['data'];
        } else {
          throw Exception('Unexpected response format');
        }
        
        secureLog('Raw cities data: $data');
        
        final citiesList = data.map((e) => CityModel.fromJson(e)).toList();

        secureLog('new citiesList length: ${citiesList.length}');
        
        secureLog('=== PARSED CITIES (${citiesList.length} total) ===');
        
        secureLog('=== END CITIES LIST ===');
        
        return citiesList;
      } else {
        throw Exception(
          response.data['message'] ??
              response.data['error'] ??
              'Failed to load cities',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          e.response?.data['message'] ??
              e.response?.data['error'] ??
              'Failed to load cities',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }
}

