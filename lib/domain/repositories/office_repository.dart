

import 'package:eprs/data/models/office_model.dart';

abstract class OfficeRepository {

  Future<List<OfficeModel>> getOffices();
} 