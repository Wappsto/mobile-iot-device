import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/wappsto.dart';

class Network {
  final String id;
  final String name;
  Wappsto _wappsto;
  List<Device> devices;

  Network({this.id, this.name, Wappsto wappsto, this.devices}) {
    _wappsto = wappsto;
  }

  factory Network.fromJson(Map<String, dynamic> json, Wappsto wappsto) {
    List<Device> devs = new List<Device>();

    Network network = Network(
      id: json['meta']['id'],
      name: json['name'],
      wappsto: wappsto,
      devices: devs,
    );

    if(json['device'] != null) {
      json['device'].forEach((dev) => devs.add(Device.fromJson(dev, network)));
    }

    return network;
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic> > devs = new List<Map<String, dynamic> >();
    devices.forEach((dev) => devs.add(dev.toJson()));

    return {
      'meta': {
        'id': id,
        'version': '2.0',
        'type': 'network',
      },
      'name': name,
      'device': devs,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Device createDevice(String name, {String version, String product, String manufacturer}) {
    var uuid = Uuid();

    Device device = new Device(id: uuid.v4(), name: name);
    device.parent = this;
    device.version = version;
    device.product = product;
    device.manufacturer = manufacturer;

    if(devices == null) {
      devices = new List<Device>();
    }
    devices.add(device);

    return device;
  }

  Device findDevice({String name}) {
    if(devices == null) {
      return null;
    }

    if(name != null) {
      return devices.firstWhere((dev) => dev.name == name, orElse: () => null);
    }

    return devices[0];
  }

  Wappsto get wappsto {
    return _wappsto;
  }

  String get url {
    return "/network/$id";
  }

  String toString() {
    return "Network '$name' ($id)";
  }
}
