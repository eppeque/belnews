library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'article.dart';

part 'serializers.g.dart';

/// Declare a top level [Serializers] field called serializers. Annotate it
/// with [SerializersFor] and provide a `const` `List` of types you want to
/// be serializable.
///
/// The built_value code generator will provide the implementation. It will
/// contain serializers for all the types asked for explicitly plus all the
/// types needed transitively via fields.
///
/// You usually only need to do this once per project.
@SerializersFor([
  ApiData,
  Article,
  Source,
])
final Serializers serializers = _$serializers;

Serializers standardSerializers = 
    (serializers.toBuilder()..addPlugin(new StandardJsonPlugin())).build();