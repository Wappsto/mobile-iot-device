import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:slx_snitch/rest.dart';
import 'package:slx_snitch/models/session.dart';
import 'package:slx_snitch/models/creator.dart';

import 'http_test_client.dart';

// buildTestEnvironment()
// import '../../config.dart';

Map<String, dynamic> _responses = Map<String, dynamic>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(_) {
    return new HttpTestClient((request, client) {
        var res;
        String type = request.uri.path.split("/").last;

        if(_responses[type] != null) {
          res = _responses[type];
        }

        if(res == null) {
          res = ["", 404];
        } else {
          res[0] = json.encode(res[0]);
        }

        // the default response is an empty 200.
        return new HttpTestResponse(body: res[0], statusCode: res[1]);
    });
  }
}

const Map<String, dynamic> fakeSessionResponse = {
  "meta": {
    "id": "123",
  },
  "username": "username",
};

const Map<String, dynamic> fakeCreatorResponse = {
  "meta": {
    "id": "123",
  },
  "network": {
    "id": "networkID",
  },
  "product": "product",
  "ca": "ca cert",
  "certificate": "certificate",
  "private_key": "private key"
};

void main() {
  final session = Session(
    id: fakeSessionResponse['meta']['id'],
    username: fakeSessionResponse['username']
  );

  final creator = Creator(
    id: fakeCreatorResponse['meta']['id'],
    network: fakeCreatorResponse['network']["id"],
    name: fakeCreatorResponse['name'],
    product: fakeCreatorResponse['product'],
    ca: fakeCreatorResponse['ca'],
    certificate: fakeCreatorResponse['certificate'],
    privateKey: fakeCreatorResponse['private_key'],
  );

  setUp(() {
      // overrides all HttpClients.
      HttpOverrides.global = new MyHttpOverrides();
  });

  tearDown(() {
  });

  test('fetch session throws an exception when user do not exist', () async {
      _responses["session"] = [{}, 401];

      expect(() => RestAPI.fetchSession("username", "password"),
        throwsA(isInstanceOf<RestException>()));
  });

  test('fetch session returns a session when user exist', () async {
      final expected = session;

      _responses["session"] = [fakeSessionResponse, 201];

      final result = await RestAPI.fetchSession("username", "password");
      expect(result, expected);
  });

  test('fetch firebase returns a session when user exist', () async {
      final expected = session;

      _responses["session"] = [fakeSessionResponse, 201];

      final result = await RestAPI.firebaseSession("token");
      expect(result, expected);
  });

  test('validate session returns a session when the session is valid', () async {
      final expected = session;

      _responses["12345"] = [fakeSessionResponse, 201];

      final result = await RestAPI.validateSession("12345");
      expect(result, expected);
  });

  test('create cretor returns a creator', () async {
      final expected = creator;

      _responses["creator"] = [fakeCreatorResponse, 201];

      final result = await RestAPI.createCreator(session, "product");
      expect(result, expected);
  });
}
