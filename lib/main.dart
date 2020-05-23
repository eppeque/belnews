import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:collection';

import 'theme_provider.dart';
import 'article.dart';
import 'belnews_bloc.dart';
import 'web_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  final belnewsBloc = BelnewsBloc();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkTheme: false),
      child: BelnewsApp(bloc: belnewsBloc),
    ),
  );
}

class BelnewsApp extends StatelessWidget {
  final BelnewsBloc bloc;

  const BelnewsApp({this.bloc});

  final _title = 'Belnews';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: _title,
      home: Home(title: _title, bloc: bloc),
      theme: themeProvider.getTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  final String title;
  final BelnewsBloc bloc;

  const Home({Key key, @required this.title, @required this.bloc})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() async {
    final connectivity = await (Connectivity().checkConnectivity());

    setState(() {
      if (connectivity == ConnectivityResult.wifi ||
          connectivity == ConnectivityResult.mobile) {
        _isConnected = true;
      } else {
        _isConnected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        leading: Opacity(
          child: Icon(FontAwesomeIcons.newspaper),
          opacity: .5,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Rechercher un article',
            onPressed: () async {
              final result = await showSearch<Article>(
                context: context,
                delegate: SearchPage(widget.bloc.articles),
              );
              if (result != null) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => WebPage(
                      url: result.url,
                      author: result.source.name,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.tune),
            tooltip: 'Accéder aux paramètres',
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
                        activeColor: Theme.of(context).accentColor,
                        value: themeProvider.isDarkTheme,
                        onChanged: (val) => themeProvider.setTheme = val,
                      ),
                    ),
                    ListTile(
                      leading: FlutterLogo(),
                      title: Text(
                          'Cette application est développée par Quentin Eppe avec Flutter.'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isConnected
          ? StreamBuilder<UnmodifiableListView<Article>>(
              stream: widget.bloc.articles,
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
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).errorColor,
                    size: 50.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Text(
                      'Il semble que vous ne soyez pas connecté à internet !',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text('Connectez-vous et relancez l\'application !'),
                ],
              ),
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
          style: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Merriweather',
          ),
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
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) =>
                        WebPage(url: article.url, author: article.source.name),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchPage extends SearchDelegate<Article> {
  Stream<UnmodifiableListView<Article>> articles;

  SearchPage(this.articles);

  @override
  String get searchFieldLabel => 'Rechercher';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        tooltip: 'Tout effacer',
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Article>>(
      stream: articles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final suggestions = snapshot.data
            .where((a) => a.title.toLowerCase().contains(query.toLowerCase()));
        return ListView(
          children: suggestions
              .map(
                (a) => Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text(
                      a.title,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    onTap: () => close(context, a),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Article>>(
      stream: articles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final suggestions = snapshot.data
            .where((a) => a.title.toLowerCase().contains(query.toLowerCase()));
        return ListView(
          children: suggestions
              .map(
                (a) => Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListTile(
                    title: Text(
                      a.title,
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    onTap: () => query = a.title,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}