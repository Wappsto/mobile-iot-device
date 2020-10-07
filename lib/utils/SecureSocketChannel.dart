import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:stream_channel/stream_channel.dart';


class SecureSocketChannel extends StreamChannelMixin {
  final String host;
  final int port;
  final String ca;
  final String cert;
  final String key;
  SecureSocket _socket;

  SecureSocketChannel({this.host, this.port, this.ca, this.cert, this.key});

  String get protocol => _socket.selectedProtocol;

  @override
  Stream get stream => SecureSocketStream._(_socket);

  @override
  SecureSocketSink get sink => SecureSocketSink._(_socket);

  SecureSocket get sock {
    return _socket;
  }

  Future<bool> connect() async {
    SecurityContext serverContext = new SecurityContext()
    ..useCertificateChainBytes(utf8.encode(cert))
    ..usePrivateKeyBytes(utf8.encode(key))
    ..setTrustedCertificatesBytes(utf8.encode(ca));

    _socket = await SecureSocket.connect(host, port, context: serverContext, onBadCertificate: (X509Certificate c) {
        print("Certificate WARNING: ${c.issuer}:${c.subject}");
        return true;
    });

    _socket.handleError(() => print("Socket Error"));

    return true;
  }
}

class SecureSocketStream extends Stream {
  final SecureSocket _socket;

  SecureSocketStream._(SecureSocket socket)
  : _socket = socket,
  super();

  @override
  StreamSubscription<String> listen(void onData(String event),
    {Function onError,
      void onDone(),
      bool cancelOnError}) {

    var sub = _socket.listen((List<int> data){
        print("Recv $data");
        onData(new String.fromCharCodes(data).trim());
      },
      onDone: onDone, cancelOnError: cancelOnError);

    SecureSocketSubscription newSub = SecureSocketSubscription._(sub);

    return newSub;
  }
}

class SecureSocketSubscription extends StreamSubscription<String> {
  final _sub;

  SecureSocketSubscription._(StreamSubscription sub)
  : _sub = sub,
  super();

  @override
  Future<E> asFuture<E>([E futureValue]) => _sub.asFuture(futureValue);

  @override
  Future<void> cancel() =>  _sub.cancel();

  @override
  bool get isPaused => _sub.isPaused;

  @override
  void onData(void handleData(String data)) {
    _sub.onData((List<int> data) => { print("Receving: ${new String.fromCharCodes(data).trim()}"), handleData(new String.fromCharCodes(data).trim()) });
  }

  @override
  void onDone(void handleDone()) => _sub.onDone(handleDone);

  @override
  void onError(Function handleError) {
    _sub.onError((dynamic err) => {print("Error. $err") , handleError});
  }

  @override
  void pause([Future resumeSignal]) => _sub.pause(resumeSignal);

  @override
  void resume() => _sub.resume();
}

class SecureSocketSink extends DelegatingStreamSink {
  SecureSocketSink._(SecureSocket socket)
  : super(socket);

  @override
  void add(dynamic data) {
    print("Adding: $data");
    super.add(utf8.encode(data));
  }
}
