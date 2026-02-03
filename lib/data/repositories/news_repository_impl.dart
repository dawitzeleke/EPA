import 'package:eprs/data/datasources/remote/news_remote_datasource.dart';
import 'package:eprs/data/models/news_model.dart';
import 'package:eprs/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NewsModel>> getNews() async {
    return await remoteDataSource.fetchNews();
  }
}