import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:stream_channel/stream_channel.dart';


class SecureSocketChannel extends StreamChannelMixin {
  final String host;
  final int port;
  final String ca;
  final String cert;
  final String key;
  SecureSocket _socket;
  StreamChannelController _controller = StreamChannelController(allowForeignErrors: false);

  SecureSocketChannel({this.host, this.port, this.ca, this.cert, this.key});

  String get protocol => _socket.selectedProtocol;

  @override
  Stream get stream => _controller.foreign.stream;

  @override
  StreamSink get sink => _controller.foreign.sink;

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
        return false;
    });

    _socket.listen((data) {
        _controller.local.sink.add(String.fromCharCodes(data).trim());
    });

    _controller.local.stream.listen((data) {
        try {
          _socket.add(utf8.encode(data));
        } catch(e) {
          print(e);
        }
    });

    _socket.handleError(() => print("Socket Error"));

    return true;
  }

  void close() {
    if(_socket != null) {
      _socket.close();
    }
  }
}
