import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:basic_utils/basic_utils.dart';

import 'SecureSocketChannel.dart';
import 'models/network.dart';
import 'models/device.dart';
import 'models/value.dart';
import 'models/state.dart';

void myIsolate(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  Peer _rpc;
  Wappsto _wappsto = null;
  bool connected = false;
  bool ready = false;
  List<List<dynamic> > waitQueue = null;

  Future<dynamic> sendToRPC(List<dynamic> data) async {
    print("Sending");
    var res = null;
    try {
      if(data[2] is String) {
        res = await _rpc.sendRequest(data[0], {'url': data[1], 'data': json.decode(data[2])});
      } else {
        res = await _rpc.sendRequest(data[0], {'url': data[1], 'data': data[2]});
      }
      print("recv");
      print(res);
    } catch(e) {
      print("ISO ERROR");
      print(e);
    }
    return res;
  }

  mainToIsolateStream.listen((data) async {
      print(data);

      if(data is List) {
        if(data.length == 5) {
          print("Connection");
          SecureSocketChannel socket = new SecureSocketChannel(host: data[0], port: data[1], ca: data[2], cert: data[3], key: data[4]);
          socket.connect().then((conn) {
              connected = true;
              ready = true;
              print("Connected $conn");
              _rpc = Peer(socket.cast<String>());

              _rpc.registerMethod('PUT', (Parameters params) {
                  Uri url = params['url'].asUri;
                  String data = params['data'].asString;
                  String id = url.pathSegments.last;

                  return true;
              });

              _rpc.registerMethod('GET', (Parameters params) {
                  Uri url = params['url'].asUri;
                  String id = url.pathSegments.last;

                  print("GET $id");
                  return true;
              });


              _rpc.listen();
          });
        } else if(!ready) {
          if(waitQueue == null) {
            waitQueue = new List<List<dynamic> >();
          }
          waitQueue.add(data);
        } else if (data.length == 3) {
          if(_rpc != null) {
            ready = false;
            await sendToRPC(data);

            while(waitQueue != null) {
              var tmp = waitQueue;
              waitQueue = null;
              for(int i=0; i<tmp.length; i++) {
                var res = await sendToRPC(tmp[i]);
              }
            }
            ready = true;
          }
        }
      }
  });

  isolateToMainStream.send('This is from myIsolate()');
}

class Wappsto {
  final String host;
  final int port;
  final String ca;
  final String cert;
  final String key;

  Network _network;
  SendPort mainToIsolateStream;

  Wappsto({this.host = "wappsto.com", this.port = 443, this.ca, this.cert, this.key});

  Future<void> connect() async {
    mainToIsolateStream = await initIsolate();

    print("Sending connect to wappsto");
    mainToIsolateStream.send([host, port, ca, cert, key]);
  }

  Network createNetwork(String name) {
    X509CertificateData data = X509Utils.x509CertificateFromPem(cert);
    String commonName = data.subject["2.5.4.3"];

    _network = new Network(id: commonName, name: name, wappsto: this);

    return _network;
  }

  Future<dynamic> postNetwork(Network network) async {
    _network = network;

    List<String> cmd = ['POST', '/network', network.toJsonString()];
    rawSend(cmd);
  }

  Future<dynamic> updateState(State state) async {
    List<String> cmd = ['PUT', state.url, state.toJsonString()];
    rawSend(cmd);
  }

  Future<dynamic> rawSend(List<String> cmd) {
    mainToIsolateStream.send(cmd);
  }

  Future<SendPort> initIsolate() async {
    Completer completer = new Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
        if (data is SendPort) {
          SendPort mainToIsolateStream = data;
          completer.complete(mainToIsolateStream);
        } else {
          print('[isolateToMainStream] $data');
        }
    });
    try {
      Isolate myIsolateInstance = await Isolate.spawn(myIsolate, isolateToMainStream.sendPort);
      return completer.future;
    } catch(e, backtrace) {
      print("ISO ERR");
      print(e);
      print(backtrace);
    }
  }

}