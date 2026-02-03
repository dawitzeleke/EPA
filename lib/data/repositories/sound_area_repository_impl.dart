import 'package:eprs/data/datasources/remote/sound_area_remote_datasource.dart';
import 'package:eprs/data/models/sound_area_model.dart';
import 'package:eprs/domain/repositories/sound_area_repository.dart';

class SoundAreaRepositoryImpl implements SoundAreaRepository {
  final SoundAreaRemoteDataSource remoteDataSource;

  SoundAreaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SoundAreaModel>> getSoundAreas() async {
    return await remoteDataSource.fetchSoundAreas();
  }
}


