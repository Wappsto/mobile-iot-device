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
    try {
      var parm = {'url': data[1]};
      if(data.length == 3) {
        if(data[2] is String) {
          parm['data'] = json.decode(data[2]);
        } else {
          parm['data'] = data[2];
        }
        parm['meta'] = {
          'fast': true
        };
      }
      return _rpc.sendRequest(data[0], parm);
    } catch(e, backtrace) {
      print("ISO ERROR");
      print(e);
      print(backtrace);
      return {'value':false};
    }
  }

  Future waitWhile(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (!test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }
    check();
    return completer.future;
  }

  Future<void> handleQueue() async {
    if(ready && _rpc != null) {
      ready = false;

      while(waitQueue != null) {
        var tmp = waitQueue;
        waitQueue = null;
        print("Queue size: ${tmp.length}");
        while(tmp.length > 0) {
          var items = tmp.take(10).toList();
          tmp.removeRange(0, items.length);
          int count = 0;
          _rpc.withBatch(() {
              for(int i=0; i<items.length; i++) {
                int id = items[i].removeLast();
                count++;
                sendToRPC(items[i]).then((res) {
                    List<dynamic> result = [id, res['value']];
                    isolateToMainStream.send(result);
                  count--;
              });
            }
          });

          await waitWhile(() => count > 0);
          print("Done sending queue ${items.length} / ${tmp.length}");
        }
      }
      ready = true;
    }
  }

  mainToIsolateStream.listen((data) async {
      if(data is List) {
        if(data.length == 2) {
          if(data[0] == "stop") {
            int len = 0;

            await waitWhile(() => !ready);

            if(waitQueue != null) {
              len = waitQueue.length;
            }

            isolateToMainStream.send([data[1], true]);

            print("Stopping isolate - Ready ${ready} Q: ${len}");
            if(_socket != null) {
              _socket.close();
            }
            mainToIsolateStream.close();
          }
        } else if(data.length == 5) {
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
  int _recvCount = 0;
  HashMap _callbacks = HashMap<int, Completer>();
  Function _progressCallback;

  int get totalEvents {
    return _sendId;
  }

  int get sendEvents {
    return _recvCount;
  }

  Wappsto({this.host = "wappsto.com", this.port = 443, this.ca, this.cert, this.key});

  Future<void> connect() async {
    mainToIsolateStream = await initIsolate();

    mainToIsolateStream.send([host, port, ca, cert, key]);
  }

  Future<void> stop() {
    return rawSend(['stop']);
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

      updateProgress();

      return c.future;
    }

    return false;
  }

  void progressStatus(Function cb) {
    _progressCallback = cb;
  }

  void updateProgress() {
    if(_progressCallback != null) {
      _progressCallback(_recvCount / _sendId);
    }
  }

  Future<SendPort> initIsolate() async {
    Completer completer = Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
        if (data is SendPort) {
          SendPort mainToIsolateStream = data;
          completer.complete(mainToIsolateStream);
        } else {
          _recvCount++;
          updateProgress();
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
