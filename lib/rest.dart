import 'dart:io';
import 'dart:convert';

import 'models/session.dart';
import 'models/creator.dart';

Future<String> fetchFromWappsto(String url, {Map jsonData, Session session}) async {
  final client = new HttpClient();
  HttpClientRequest request;

  if(jsonData != null) {
    request = await client.postUrl(Uri.parse(url))
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(jsonData));
  } else if(session != null) {
    request = await client.getUrl(Uri.parse(url))
    ..headers.set('x-session', session.id);
  } else {
    request = await client.getUrl(Uri.parse(url));
  }

  HttpClientResponse response = await request.close();
  final body = await utf8.decoder.bind(response).join();

  if (response.statusCode == 200 || response.statusCode == 201) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception("Failed to load data from Wappsto ${response.statusCode}: ${url}");
  }
}

Future<Session> fetchSession(String username, String password) async {
  String url = 'https://wappsto.com/services/2.0/session';
  Map jsonData = {
    'username': username,
    'password': password,
  };
  final data = await fetchFromWappsto(url, jsonData: jsonData);
  return Session.fromJson(json.decode(data));
}

Future<List<Creator> > fetchCreator(Session session) async {
  String url = 'https://wappsto.com/services/2.0/creator?expand=1';

  final data = await fetchFromWappsto(url, session: session);
  final list = json.decode(data);
  List<Creator> creators = new List<Creator>();
  list.forEach((elm) => {
      creators.add(Creator.fromJson(elm))
  });
  return creators;
}

Future<Session> validateSession(String id) async {
  String url = 'https://wappsto.com/services/2.0/session/${id}';

  final data = await fetchFromWappsto(url);
  return Session.fromJson(json.decode(data));
}
