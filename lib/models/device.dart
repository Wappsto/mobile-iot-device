import 'package:uuid/uuid.dart';
import 'package:mobile_iot_device/models/network.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/wappsto.dart';

class Device {
  final String id;
  final String name;
  String manufacturer = null;
  String product = null;
  String version = null;
  String serial = null;
  String description = null;
  String protocol = null;
  String communication = null;

  Network parent = null;
  List<Value> values;

  Device({this.id, this.name, this.values = null, this.parent = null}) {
    values = new List<Value>();
  }

  factory Device.fromJson(Map<String, dynamic> json, Network parent) {
    List<Value> vals = new List<Value>();

    Device device = Device(
      id: json['meta']['id'],
      name: json['name'],
      values: vals,
      parent: parent,
    );

    json['value'].forEach((val) => device.values.add(Value.fromJson(val, device)));

    if(json['manufacturer'] != null) {
      device.manufacturer = json['manufacturer'];
    }

    if(json['product'] != null) {
      device.product = json['product'];
    }

    if(json['version'] != null) {
      device.version = json['version'];
    }

    if(json['serial'] != null) {
      device.serial = json['serial'];
    }

    if(json['description'] != null) {
      device.description = json['description'];
    }

    if(json['protocol'] != null) {
      device.protocol = json['protocol'];
    }

    if(json['communication'] != null) {
      device.communication = json['communication'];
    }

    return device;
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic> > vals = new List<Map<String, dynamic> >();
    values.forEach((val) => vals.add(val.toJson()));

    var device = {
      'meta': {
        'id': id,
        'version': '2.0',
        'type': 'device',
      },
      'name': name,
      'value': vals,
    };

    if(manufacturer != null) {
      device['manufacturer'] = manufacturer;
    }

    if(product != null) {
      device['product'] = product;
    }

    if(version != null) {
      device['version'] = version;
    }

    if(serial != null) {
      device['serial'] = serial;
    }

    if(description != null) {
      device['description'] = description;
    }

    if(protocol != null) {
      device['protocol'] = protocol;
    }

    if(communication != null) {
      device['communication'] = communication;
    }

    return device;
  }

  Value _createValue(String name, String type) {
    var uuid = Uuid();
    Value value = new Value(id: uuid.v4(), name: name, type: type);
    value.parent = this;

    values.add(value);

    return value;
  }

  Value createNumberValue(String name, String type, int min, int max, double step, String unit) {
    Value value = _createValue(name, type);

    value.createNumber(min, max, step, unit);

    return value;
  }

  Value createStringValue(String name, String type, int max) {
    Value value = _createValue(name, type);

    value.createString(max);

    return value;
  }

  Value findValue({String name}) {
    if(values.isEmpty) {
      return null;
    }

    if(name != null) {
      return values.firstWhere((val) => val.name == name, orElse: () => null);
    }

    return values[0];
  }

  Wappsto get wappsto {
    return parent.wappsto;
  }

  String get url {
    return "${parent.url}/device/${id}";
  }

  String toString() {
    return "Device '${name}' (${id})";
  }
}
