import 'package:eprs/data/models/awareness_model.dart';
import 'package:eprs/domain/repositories/awareness_repository.dart';

class GetAwarenessUseCase {
  final AwarenessRepository repository;

  GetAwarenessUseCase({required this.repository});

  Future<List<AwarenessModel>> execute() async {
    return await repository.getAwareness();
  }
}

