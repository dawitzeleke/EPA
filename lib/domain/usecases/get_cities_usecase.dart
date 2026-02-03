import 'package:eprs/data/models/city_model.dart';
import 'package:eprs/domain/repositories/city_repository.dart';

class GetCitiesUseCase {
  final CityRepository repository;

  GetCitiesUseCase({required this.repository});

  Future<List<CityModel>> execute() async {
    return await repository.getCities();
  }
}

