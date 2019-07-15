import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'dart:async';
import 'dart:convert';

final apiKey = "";
final apiSecret = "";

class Tweet {
  String tweet = "";
  String username = "";
  Tweet(this.tweet, this.username);
}

class RandomWordsState2 extends State<RandomWords2> {
  final _suggestions = <Tweet>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  var length;
  var page = 1;

  Future<void> getTimeline() async {
    Twitter twitter = new Twitter(apiKey, apiSecret, '', '');
    var response = await twitter.request(
        "GET", "statuses/mentions_timeline.json?page=$page");
    List parsedList = jsonDecode(response.body);
    twitter.close();
    setState(() {
      page += 1;
      for (var i = 0; i < parsedList.length; ++i) {
        _suggestions
            .add(Tweet(parsedList[i]["text"], parsedList[i]["user"]["name"]));
      }
    });
  }

  // #enddocregion RWS-var
  void _incrementCounter() {
    setState(() {
      // getClient();
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
            //getTimeline();
            // 画面にはローディング表示しておく
            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
              ),
            );
          } else if (i > length) {
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
