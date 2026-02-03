import 'package:eprs/data/models/city_model.dart';

abstract class CityRepository {
  Future<List<CityModel>> getCities();
}

