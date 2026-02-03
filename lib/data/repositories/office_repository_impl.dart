

import 'package:eprs/data/datasources/remote/office_remote_datasource.dart';
import 'package:eprs/data/models/office_model.dart';
import 'package:eprs/domain/repositories/office_repository.dart';

class OfficeRepositoryImpl implements OfficeRepository {
  final OfficeRemoteDataSource remoteDataSource;
  
  OfficeRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<OfficeModel>> getOffices() async {
    return await remoteDataSource.fetchOffices();
  }
}