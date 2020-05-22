# Belnews

Toute l'actualité du plat pays !

## Getting Started

This project is a Flutter app.

To run your app: run the `$ flutter run` command.

We use the `built_value` package to deserialize the JSON data. If you change something in the `article.dart` file run `$ flutter pub run build_runner build` to generate the new code.

This app uses the News API. To be able to receive the data from this API you must have an API key. To add it to this project create the `api_key.dart` file to the `/lib` directory and add this code:

```dart
final apiKey = '<Your API key>';
```

The app will automatically use this key!