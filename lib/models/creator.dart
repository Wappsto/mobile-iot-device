import 'dart:convert';

class Creator {
  final String id;
  final String network;
  final String name;
  final String ca;
  final String certificate;
  final String private_key;

  Creator({this.id, this.network, this.name, this.ca, this.certificate, this.private_key});

  factory Creator.fromJson(Map<String, dynamic> jsonData) {
    String network;
    String name;

    if(jsonData.containsKey('data')) {
      if(jsonData['data'] is String) {
        final d = json.decode(jsonData['data']);
        if(d.containsKey('meta')) {
          network = d['meta']['id'];
          name = d['name'];
        }
      }
    }
    return Creator(
      ca: jsonData['ca'],
      certificate: jsonData['certificate'],
      private_key: jsonData['private_key'],
      id: jsonData['meta']['id'],
      network: network,
      name: name,
    );
  }

  String toString() {
    return "Creator ${id} - Network ${network} ${name}";
  }
}
