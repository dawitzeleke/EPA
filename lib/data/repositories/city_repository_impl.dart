import 'package:eprs/data/datasources/remote/city_remote_datasource.dart';
import 'package:eprs/data/models/city_model.dart';
import 'package:eprs/domain/repositories/city_repository.dart';

class CityRepositoryImpl implements CityRepository {
  final CityRemoteDataSource remoteDataSource;

  CityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CityModel>> getCities() async {
    return await remoteDataSource.fetchCities();
  }
}

