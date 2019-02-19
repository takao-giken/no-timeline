import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'package:oauth2/oauth2.dart';
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

final requestTokenEndPoint =
    Uri.parse("https://api.twitter.com/oauth/request_token");
final accessTokenEndPoint =
    Uri.parse("https://api.twitter.com/oauth/authorize");
final redirectUrl = Uri.parse("http://localhost:8080/");
final identifier = "my client identifier";
final secret = "my client secret";

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

  void _incrementCounter() {
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

class Tweet {
  String tweet="";
  String username="";
  Tweet(this.tweet,this.username);
}

class RandomWordsState2 extends State<RandomWords2> {
  final _suggestions = <Tweet>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  int _counter = 0;
  var length;
  var page = 1;

  Future<void> getTimeline() async {
      Twitter twitter= new Twitter();
      var response = await twitter.request("GET", "statuses/mentions_timeline.json?page=${page}");
      List parsedList = jsonDecode(response.body);
      twitter.close();
      setState(() {
        page += 1;
        for(var i=0;i<parsedList.length;++i){
          _suggestions.add(Tweet(parsedList[i]["text"],parsedList[i]["user"]["name"]));
        }
      });
}

  // #enddocregion RWS-var
  void _incrementCounter() {
    setState(() {
      _counter++;
      getTimeline();
    });
  }

  // #docregion _buildSuggestions
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          //final index = i ~/ 2; /*3*/
          if (i == length) {
            //_suggestions.addAll(getTimeline()); /*4*/
            getTimeline();
            // 画面にはローディング表示しておく
            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
              ),
            );
          }else if(i > length){
            return null;
          }
          return _buildRow(_suggestions[i]);
        });
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(Tweet pair) {
    return ListTile(
      title: Text(
        pair.tweet,
        style: _biggerFont,
      ),
    );
  }
  // #enddocregion _buildRow

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    length = _suggestions?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildSuggestions(),
            floatingActionButton: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
    );
  }
  // #enddocregion RWS-build
  // #docregion RWS-var
}
// #enddocregion RWS-var

class RandomWords2 extends StatefulWidget {
  final String title;
  RandomWords2({Key key, this.title}) : super(key: key);

  @override
  RandomWordsState2 createState() => new RandomWordsState2();
}
