import 'package:flutter/material.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;

import 'package:no_timeline/timeline.dart';
import 'package:no_timeline/twitter_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './env.dart';
//import 'package:flutter_keychain/flutter_keychain.dart';

void main() {
  // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(new MyApp());
}

final apiKey = EnvironmentConfig.API_KEY;
final apiSecret = EnvironmentConfig.API_SECRET;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      home: BasePage(),
    );
  }
}

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}
class _BasePageState extends State<BasePage> {

  // page index
  int _index = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              this._index = index;
            });
          },
          children: [
            RandomWords2(title: "Notifications"), //call pages
            RandomWords(title: "Direct Messages"),
          ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) { // define animation
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 10), curve: Curves.ease);
        },
        currentIndex: _index,
        items: [
          BottomNavigationBarItem( // call each bottom item
            icon: new Icon(Icons.notifications),
            title: new Text('Notifications'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.message),
            title: new Text('DM'),
          )
        ],
      ),
    );
  }
}

// #docregion RandomWordsState, RWS-class-only
class RandomWordsState extends State<RandomWords> {
  int _counter = 0;

  void _incrementCounter() async{
    Token token = await getToken(apiKey, apiSecret);
    print(token.accessToken);
    print(token.accessTokenSecret);

    //await FlutterKeychain.put(key: "accessToken",value:token.accessToken);
    //await FlutterKeychain.put(key: "accessTokenSecret",value:token.accessTokenSecret);
    
    final storage = new FlutterSecureStorage();
    await storage.write(key:'accessToken',value:token.accessToken);
    await storage.write(key:'accessTokenSecret',value:token.accessTokenSecret);
    
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), 
    );
  }
}
// #enddocregion RandomWordsState, RWS-class-only

// #docregion RandomWords
class RandomWords extends StatefulWidget {
  RandomWords({Key key, this.title}) : super(key: key);

  final String title;
  @override
  RandomWordsState createState() => new RandomWordsState();
}
