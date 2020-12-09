import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'dart:collection';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:basic_utils/basic_utils.dart';

import 'package:slx_snitch/utils/SecureSocketChannel.dart';
import 'package:slx_snitch/models/network.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

void myIsolate(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  Peer _rpc;
  bool ready = false;
  List<List<dynamic> > waitQueue;
  SecureSocketChannel _socket;

  Future<dynamic> sendToRPC(List<dynamic> data) async {
    var res;
    try {
      if(data.length == 2) {
        res = await _rpc.sendRequest(data[0], {'url': data[1]});
      } else {
        if(data[2] is String) {
          res = await _rpc.sendRequest(data[0], {'url': data[1], 'data': json.decode(data[2])});
        } else {
          res = await _rpc.sendRequest(data[0], {'url': data[1], 'data': data[2]});
        }
      }
    } catch(e, backtrace) {
      print("ISO ERROR");
      print(e);
      print(backtrace);
      res = {'value':false};
    }
    return res;
  }

  Future<void> handleQueue() async {
    if(ready && _rpc != null) {
      ready = false;

      while(waitQueue != null) {
        var tmp = waitQueue;
        waitQueue = null;
        for(int i=0; i<tmp.length; i++) {
          int id = tmp[i].removeLast();
          var res = await sendToRPC(tmp[i]);

          List<dynamic> result = [id, res['value']];
          isolateToMainStream.send(result);
        }
      }
      ready = true;
    }
  }

  mainToIsolateStream.listen((data) async {
      if(data is List) {
        if(data.length == 5) {
          _socket = SecureSocketChannel(host: data[0], port: data[1], ca: data[2], cert: data[3], key: data[4]);
          _socket.connect().then((conn) {
              _rpc = Peer(_socket.cast<String>());

              _rpc.registerMethod('PUT', (Parameters params) {
                  // Uri url = params['url'].asUri;
                  // String data = params['data'].asString;
                  // String id = url.pathSegments.last;

                  return false;
              });

              _rpc.registerMethod('GET', (Parameters params) {
                  // Uri url = params['url'].asUri;
                  // String id = url.pathSegments.last;

                  return false;
              });

              _rpc.listen();

              ready = true;
              handleQueue();
          });
        } else {
          if(waitQueue == null) {
            waitQueue = List<List<dynamic> >();
          }
          waitQueue.add(data);
          await handleQueue();
        }
      } else {
        if(data == "stop") {
          if(_socket != null) {
            print("Stopping isolate");
            _socket.close();
            mainToIsolateStream.close();
          }
        }
      }
  });
}

class Wappsto {
  final String host;
  final int port;
  final String ca;
  final String cert;
  final String key;

  Network _network;
  SendPort mainToIsolateStream;
  int _sendId = 0;
  HashMap _callbacks = HashMap<int, Completer>();

  Wappsto({this.host = "wappsto.com", this.port = 443, this.ca, this.cert, this.key});

  Future<void> connect() async {
    mainToIsolateStream = await initIsolate();

    mainToIsolateStream.send([host, port, ca, cert, key]);
  }

  void stop() {
    if(mainToIsolateStream != null) {
      mainToIsolateStream.send("stop");
    }
  }

  Network createNetwork(String name) {
    X509CertificateData data = X509Utils.x509CertificateFromPem(cert);
    String commonName = data.subject["2.5.4.3"];

    _network = Network(id: commonName, name: name, wappsto: this);

    return _network;
  }

  Future<bool> postNetwork(Network network) async {
    _network = network;

    List<String> cmd = ['POST', '/network', network.toJsonString()];
    return await rawSend(cmd);
  }

  Future<bool> updateState(State state) async {
    List<String> cmd = ['PUT', state.url, state.toJsonString()];
    return await rawSend(cmd);
  }

  Future<bool> deleteValue(Value value) async {
    List<String> cmd = ['DELETE', value.url];
    return await rawSend(cmd);
  }

  Future<bool> rawSend(List<String> cmd) async {
    if(mainToIsolateStream != null) {
      _sendId++;
      Completer c = Completer<bool>();
      List<dynamic> tmp = List();
      tmp.addAll(cmd);
      tmp.add(_sendId);
      _callbacks[_sendId] = c;

      mainToIsolateStream.send(tmp);

      return c.future;
    }

    return false;
  }

  Future<SendPort> initIsolate() async {
    Completer completer = Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
        if (data is SendPort) {
          SendPort mainToIsolateStream = data;
          completer.complete(mainToIsolateStream);
        } else {
          if(_callbacks[data[0]] != null) {
            _callbacks[data[0]].complete(data[1]);
            _callbacks.remove(data[0]);
          }
        }
    });

    try {
      await Isolate.spawn(myIsolate, isolateToMainStream.sendPort);
      return completer.future;
    } catch(e, backtrace) {
      print("ISO ERR");
      print(e);
      print(backtrace);
      return null;
    }
  }
}
