import 'package:eprs/data/models/sound_area_model.dart';

abstract class SoundAreaRepository {
  Future<List<SoundAreaModel>> getSoundAreas();
}


