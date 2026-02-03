import 'package:eprs/data/models/office_model.dart';
import 'package:eprs/domain/repositories/office_repository.dart';

class GetOfficesUsecase {
  final OfficeRepository repository;

  GetOfficesUsecase({required this.repository});

  Future<List<OfficeModel>> execute() async {
    return await repository.getOffices();
  }
}