import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'article.dart';
import 'api_key.dart';

import 'dart:collection';

class BelnewsBloc {
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;
  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  BelnewsBloc() {
    _getArticlesAndUpdate();
  }

  List<Article> _articles = [];

  Future<List<Article>> _getArticles() async {
    final url =
        'https://newsapi.org/v2/top-headlines?country=be&apiKey=$apiKey';
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final articles = parseArticles(res.body);
      return articles;
    }
    throw NewsApiError("An error occured while the fetch of the articles");
  }

  Future<Null> _updateArticles() async {
    await _getArticles().then((articles) => _articles = articles);
  }

  _getArticlesAndUpdate() async {
    await _updateArticles();
    _articlesSubject.add(UnmodifiableListView(_articles));
  }
}

class NewsApiError extends Error {
  final String message;

  NewsApiError(this.message);
}