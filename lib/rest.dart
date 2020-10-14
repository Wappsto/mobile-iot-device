import 'dart:io';
import 'dart:convert';

import 'package:mobile_iot_device/models/session.dart';
import 'package:mobile_iot_device/models/creator.dart';

final String host = 'https://wappsto.com/services';

class RestException implements Exception {
  String message;
  String result;
  RestException(this.message, this.result);

  String toString() {
    return "$message ($result)";
  }
}

class RestAPI {
  static Future<String> fetchFromWappsto(String url, {Map jsonData, String session, bool patch}) async {
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
        if(patch == null) {
          request = await client.postUrl(Uri.parse(url))
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(jsonData));
        } else {
          request = await client.patchUrl(Uri.parse(url))
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(jsonData));
        }
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
      throw RestException("Failed to load data from Wappsto ${response.statusCode}: $url", json.decode(body)['message']);
    }
  }

  static Future<Session> fetchSession(String username, String password) async {
    String url = "$host/2.1/session";
    Map jsonData = {
      'username': username,
      'password': password,
    };
    final data = await fetchFromWappsto(url, jsonData: jsonData);
    return Session.fromJson(json.decode(data));
  }

  static Future<Session> firebaseSession(String token) async {
    String url = "$host/2.1/session";
    Map jsonData = {
      'firebase_token': token
    };
    final data = await fetchFromWappsto(url, jsonData: jsonData);
    return Session.fromJson(json.decode(data));
  }

  static Future<List<Creator> > fetchCreator(Session session) async {
    String url = "$host/2.1/creator?expand=1";

    final data = await fetchFromWappsto(url, session: session.id);
    final list = json.decode(data);

    List<Creator> creators = new List<Creator>();
    list.forEach((elm) => {
        creators.add(Creator.fromJson(elm))
    });
    return creators;
  }

  static Future<Creator> createCreator(Session session, String product) async {
    String url = "$host/2.1/creator";
    Map jsonData = {
      'product': product
    };
    final data = await fetchFromWappsto(url, jsonData: jsonData, session: session.id);
    return Creator.fromJson(json.decode(data));
  }

  static Future<Session> validateSession(String id) async {
    String url = "$host/2.0/session/$id";

    try {
      final data = await fetchFromWappsto(url, session: id);
      return Session.fromJson(json.decode(data));
    } catch(e) {
      print("Session is not valid");
    }

    return null;
  }

  static Future<String> signup(String email, String password) async {
    String url = "$host/2.1/register";

    Map jsonData = {
      'username': email,
      'password': password
    };

    try {
      final data = await fetchFromWappsto(url, jsonData: jsonData);
      print(data);
      return "ok";
    } catch(e) {
      print("Failed to signup to wappsto");
      print(e);
    }

    return null;
  }

  static Future<String> resetPassword(String email) async {
    String url = "$host/2.1/register/recovery_password";

    Map jsonData = {
      'username': email
    };

    try {
      final data = await fetchFromWappsto(url, jsonData: jsonData, patch: true);
      return json.decode(data)['message'];
    } catch(e) {
      print("Failed to recover password");
      print(e);
    }

    return null;
  }

  static Future<String> claimNetwork(String session, String network) async {
    String url = "$host/2.0/network/$network";

    Map jsonData = {};

    try {
      final data = await fetchFromWappsto(url, session: session, jsonData: jsonData);
      return data;
    } catch(e) {
      print("Failed to claim network");
      print(e);
    }

    return null;
  }
}
