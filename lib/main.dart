import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme_provider.dart';
import 'article.dart';
import 'api_key.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkTheme: false),
      child: BelnewsApp(),
    ),
  );
}

class BelnewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Belnews',
      home: Home(title: 'Gros titres'),
      theme: themeProvider.getTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  final String title;

  const Home({Key key, this.title}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Article>> _getArticles() async {
    final url =
        'https://newsapi.org/v2/top-headlines?country=be&apiKey=$apiKey';
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final articles = parseArticles(res.body);
      return articles;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.tune),
            color: Theme.of(context).accentColor,
            onPressed: () => showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              context: context,
              builder: (context) => Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.brightness_medium,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text('Thème sombre'),
                      trailing: Switch(
                        value: themeProvider.isDarkTheme,
                        onChanged: (val) => themeProvider.setTheme = val,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _getArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data.map(_buildItem).toList(),
          );
        },
      ),
    );
  }

  Widget _buildItem(Article article) {
    final time = DateTime.parse(article.publishedAt);
    final formatted = DateFormat('d/M/y H:m:s').format(time);
    return Padding(
      key: Key(article.title),
      padding: EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(
          article.title,
          style: TextStyle(fontSize: 24.0),
        ),
        subtitle: Text(article.source.name),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(formatted),
              IconButton(
                icon: Icon(
                  Icons.launch,
                  color: Colors.green,
                ),
                onPressed: () async {
                  if (await canLaunch(article.url)) {
                    launch(article.url);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}