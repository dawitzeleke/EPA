import 'package:eprs/data/datasources/remote/awareness_remote_datasource.dart';
import 'package:eprs/data/models/awareness_model.dart';
import 'package:eprs/domain/repositories/awareness_repository.dart';

class AwarenessRepositoryImpl implements AwarenessRepository {
  final AwarenessRemoteDataSource remoteDataSource;
  
  AwarenessRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<AwarenessModel>> getAwareness() async {
    return await remoteDataSource.fetchAwareness();
  }
}

