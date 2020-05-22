import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

import 'serializers.dart';

import 'dart:convert';

part 'article.g.dart';

abstract class ApiData implements Built<ApiData, ApiDataBuilder> {
  static Serializer<ApiData> get serializer => _$apiDataSerializer;

  String get status;

  int get totalResults;

  BuiltList<Article> get articles;

  ApiData._();
  factory ApiData([void Function(ApiDataBuilder) updates]) = _$ApiData;
}

abstract class Article implements Built<Article, ArticleBuilder> {
  static Serializer<Article> get serializer => _$articleSerializer;

  @nullable
  Source get source;

  @nullable
  String get author;

  @nullable
  String get title;

  @nullable
  String get description;

  @nullable
  String get url;

  @nullable
  String get urlToImage;

  @nullable
  String get publishedAt;

  @nullable
  String get content;

  Article._();
  factory Article([void Function(ArticleBuilder) updates]) = _$Article;
}

abstract class Source implements Built<Source, SourceBuilder> {
  static Serializer<Source> get serializer => _$sourceSerializer;

  @nullable
  String get id;

  @nullable
  String get name;

  Source._();
  factory Source([void Function(SourceBuilder) updates]) = _$Source;
}

List<Article> parseArticles(String jsonString) {
  final parsed = jsonDecode(jsonString);
  final articles = standardSerializers.deserializeWith(ApiData.serializer, parsed).articles.toList();
  return articles;
}