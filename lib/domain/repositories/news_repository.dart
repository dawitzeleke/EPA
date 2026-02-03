
import 'package:eprs/data/models/news_model.dart';

abstract class NewsRepository {
  Future<List<NewsModel>> getNews();
}

