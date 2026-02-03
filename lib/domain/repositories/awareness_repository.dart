import 'package:eprs/data/models/awareness_model.dart';

abstract class AwarenessRepository {
  Future<List<AwarenessModel>> getAwareness();
}

