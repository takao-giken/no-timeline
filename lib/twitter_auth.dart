import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:oauth/oauth.dart' as oauth;

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

_launchURL(String url) async {
  if (await canLaunch(url)) await launch(url);
  else throw 'Could not launch $url';
}

Future<Stream<String>> _server() async {
  final StreamController<String> onCode = new StreamController();
  HttpServer server =
  await HttpServer.bind(InternetAddress.loopbackIPv4, 8080, shared: true);
  server.listen((HttpRequest request) async {
    final String oauthVerifier = request.uri.queryParameters["oauth_verifier"];
    request.response
      ..statusCode = 200
      ..headers.set("Content-Type", ContentType.html.mimeType)
      ..write("<html><h1>You can now close this window</h1></html>");
    await request.response.close();
    await server.close(force: true);
    onCode.add(oauthVerifier);
    await onCode.close();
  });
  return onCode.stream;
}

Future<Token> getToken(String consumerKey, String consumerSecret) async {
  Stream<Object> onCode = await _server();
  oauth.Client client = oauth.Client(oauth.Tokens(
    consumerId: consumerKey, 
    consumerKey: consumerSecret
  ));
  final http.Response response = await client.post(
      "https://api.twitter.com/oauth/request_token?oauth_callback=" + Uri.encodeComponent("http://localhost:8080/"));
  final tmp = new Token.fromMap(Uri.splitQueryString(response.body));
  String url =
      "https://api.twitter.com/oauth/authorize?oauth_token=${tmp.accessToken}";
  _launchURL(url);
  final String oauthVerifier = await onCode.first;
  oauth.Client client2 = oauth.Client(oauth.Tokens(
    consumerId: consumerKey, 
    consumerKey: consumerSecret,
    userId: tmp.accessToken,
    userKey: tmp.accessTokenSecret
  ));
  final http.Response response2 = await client2.post(
      "https://api.twitter.com/oauth/access_token?oauth_verifier=$oauthVerifier");
  return new Token.fromMap(Uri.splitQueryString(response2.body));
}
class Token {
  final String accessToken;
  final String accessTokenSecret;

  Token(this.accessToken, this.accessTokenSecret);

  Token.fromMap(Map<String, dynamic> json)
      : accessToken = json['oauth_token'],
        accessTokenSecret = json['oauth_token_secret'];
}