import 'package:eprs/data/models/sound_area_model.dart';
import 'package:eprs/domain/repositories/sound_area_repository.dart';

class GetSoundAreasUseCase {
  final SoundAreaRepository repository;

  GetSoundAreasUseCase({required this.repository});

  Future<List<SoundAreaModel>> execute() async {
    return await repository.getSoundAreas();
  }
}


