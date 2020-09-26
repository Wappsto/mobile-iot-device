import 'dart:io';
import 'dart:convert';

import 'package:mobile_iot_device/models/session.dart';
import 'package:mobile_iot_device/models/creator.dart';

final String host = 'https://wappsto.com/services';

Future<String> fetchFromWappsto(String url, {Map jsonData, String session}) async {
  final client = new HttpClient();
  HttpClientRequest request;

  if(session != null) {
    if(jsonData != null) {
      request = await client.postUrl(Uri.parse(url))
      ..headers.contentType = ContentType.json
      ..headers.set('x-session', session)
      ..write(jsonEncode(jsonData));
    } else {
      request = await client.getUrl(Uri.parse(url))
      ..headers.set('x-session', session);
    }
  } else {
    if(jsonData != null) {
      request = await client.postUrl(Uri.parse(url))
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(jsonData));
    } else {
      request = await client.getUrl(Uri.parse(url));
    }
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
  String url = "${host}/2.0/session";
  Map jsonData = {
    'username': username,
    'password': password,
  };
  final data = await fetchFromWappsto(url, jsonData: jsonData);
  print(data);
  return Session.fromJson(json.decode(data));
}

Future<List<Creator> > fetchCreator(Session session) async {
  String url = "${host}/2.0/creator?expand=1";

  final data = await fetchFromWappsto(url, session: session.id);
  final list = json.decode(data);

  List<Creator> creators = new List<Creator>();
  list.forEach((elm) => {
      creators.add(Creator.fromJson(elm))
  });
  return creators;
}

Future<Creator> createCreator(Session session) async {
  String url = "${host}/2.1/creator";
  Map jsonData = {};
  final data = await fetchFromWappsto(url, jsonData: jsonData, session: session.id);
  print(data);
  return Creator.fromJson(json.decode(data));
}

Future<Session> validateSession(String id) async {
  String url = "${host}/2.0/session/${id}";

  try {
    final data = await fetchFromWappsto(url, session: id);
    return Session.fromJson(json.decode(data));
  } catch(e) {
    print("Session is not valied");
  }

  return null;
}
