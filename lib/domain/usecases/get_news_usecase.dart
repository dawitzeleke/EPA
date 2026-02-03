

import 'package:eprs/data/models/news_model.dart';
import 'package:eprs/domain/repositories/news_repository.dart';

class GetNewsUseCase {
  final NewsRepository repository;

  GetNewsUseCase({required this.repository});

  Future<List<NewsModel>> execute() async {
    return await repository.getNews();
  }
}

