import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';

import 'dart:collection';
import 'dart:async';

import 'theme_provider.dart';
import 'article.dart';
import 'belnews_bloc.dart';

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
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        if (result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile) {
          _isConnected = true;
        } else {
          _isConnected = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Il semble que vous ne soyez pas connecté à internet !',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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