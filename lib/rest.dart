import 'dart:io';
import 'dart:convert';

import 'package:slx_snitch/host.dart';
import 'package:slx_snitch/models/network.dart';
import 'package:slx_snitch/models/session.dart';
import 'package:slx_snitch/models/creator.dart';

class RestException implements Exception {
  String message;
  String result;
  RestException(this.message, this.result);

  String toString() {
    return "$message ($result)";
  }
}

class RestAPI {
  static final RestAPI _instance = RestAPI._internal();
  HttpClient client = HttpClient();

  factory RestAPI() {
    return _instance;
  }

  RestAPI._internal();

  Future<String> fetchFromWappsto(String url, {Map jsonData, String session, bool patch}) async {
    url = "https://$host/services/$url";
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
      try {
        throw RestException("Failed to load data from Wappsto ${response.statusCode}: $url", json.decode(body)['message']);
      } catch(e) {
        throw RestException("Failed to load data from Wappsto ${response.statusCode}: $url", body);
      }
    }
  }

  static Future<Session> fetchSession(String username, String password) async {
    String url = "2.1/session";
    Map jsonData = {
      'username': username,
      'password': password,
      'remember_me': true
    };
    final data = await RestAPI().fetchFromWappsto(url, jsonData: jsonData);
    try {
      return Session.fromJson(json.decode(data));
    } catch(e) {
      return null;
    }
  }

  static Future<Session> firebaseSession(String token) async {
    String url = "2.1/session";
    Map jsonData = {
      'firebase_token': token
    };
    final data = await RestAPI().fetchFromWappsto(url, jsonData: jsonData);
    return Session.fromJson(json.decode(data));
  }

  static Future<List<Creator> > fetchCreator(Session session) async {
    String url = "2.1/creator?expand=1";

    final data = await RestAPI().fetchFromWappsto(url, session: session.id);
    final list = json.decode(data);

    List<Creator> creators = new List<Creator>();
    list.forEach((elm) => {
        creators.add(Creator.fromJson(elm))
    });
    return creators;
  }

  static Future<Creator> createCreator(Session session, String product) async {
    String url = "2.1/creator";
    Map jsonData = {
      'product': product
    };
    final data = await RestAPI().fetchFromWappsto(url, jsonData: jsonData, session: session.id);
    return Creator.fromJson(json.decode(data));
  }

  static Future<Session> validateSession(String id) async {
    String url = "2.0/session/$id";

    try {
      final data = await RestAPI().fetchFromWappsto(url, session: id);
      return Session.fromJson(json.decode(data));
    } catch(e) {
      print("Session is not valid");
    }

    return null;
  }

  static Future<String> signup(String email, String password) async {
    String url = "2.1/register";

    Map jsonData = {
      'username': email,
      'password': password
    };

    try {
      await RestAPI().fetchFromWappsto(url, jsonData: jsonData);
      return "ok";
    } catch(e) {
      print("Failed to signup to wappsto");
      print(e);
    }

    return null;
  }

  static Future<String> resetPassword(String email) async {
    String url = "2.1/register/recovery_password";

    Map jsonData = {
      'username': email
    };

    try {
      final data = await RestAPI().fetchFromWappsto(url, jsonData: jsonData, patch: true);
      return json.decode(data)['message'];
    } catch(e) {
      print("Failed to recover password");
      print(e);
    }

    return null;
  }

  static Future<String> claimNetwork(String session, String network) async {
    String url = "2.0/network/$network";

    Map jsonData = {};

    try {
      final data = await RestAPI().fetchFromWappsto(url, session: session, jsonData: jsonData);
      return data;
    } catch(e) {
      print("Failed to claim network");
      print(e);
    }

    return null;
  }

  static Future<List<Network> > fetchNetworks(String session) async {
    String url = "2.0/network?expand=1";

    final data = await RestAPI().fetchFromWappsto(url, session: session);
    final list = json.decode(data);

    List<Network> networks = new List<Network>();
    list.forEach((elm) => {
        elm.removeWhere((key, value) => key == "device"),
        networks.add(Network.fromJson(elm, null))
    });
    return networks;
  }

  static Future<Network> fetchNetwork(String session, String network) async {
    String url = "2.0/network/$network";

    final data = await RestAPI().fetchFromWappsto(url, session: session);
    Map<String, dynamic> j = json.decode(data);

    j.removeWhere((key, value) => key == "device");
    return Network.fromJson(j, null);
  }

  static Future<Network> fetchFullNetwork(String session, String network, var wappsto) async {
    String url = "2.0/network/$network?expand=5";

    final data = await RestAPI().fetchFromWappsto(url, session: session);
    Map<String, dynamic> j = json.decode(data);

    return Network.fromJson(j, wappsto);
  }
}
