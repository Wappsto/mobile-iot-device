import 'dart:convert';

class Creator {
  final String id;
  final String network;
  final String name;
  final String ca;
  final String certificate;
  final String privateKey;
  final String product;

  Creator({this.id, this.network, this.name, this.ca, this.certificate, this.privateKey, this.product});

  factory Creator.fromJson(Map<String, dynamic> jsonData) {
    String network;
    String name;
    String product;

    if(jsonData.containsKey('data')) {
      if(jsonData['data'] is String) {
        print(jsonData['data']);
        final d = json.decode(jsonData['data']);
        if(d.containsKey('meta')) {
          network = d['meta']['id'];
          name = d['name'];
        }
      }
    }

    if(jsonData.containsKey('product')) {
      product = jsonData['product'];
    }

    return Creator(
      ca: jsonData['ca'],
      certificate: jsonData['certificate'],
      privateKey: jsonData['private_key'],
      id: jsonData['meta']['id'],
      network: network,
      name: name,
      product: product,
    );
  }

  String toString() {
    return "Creator $id - Product $product - Network $network $name";
  }
}
