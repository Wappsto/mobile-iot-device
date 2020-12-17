import 'package:uuid/uuid.dart';
import 'package:slx_snitch/models/wappsto_model.dart';
import 'package:slx_snitch/models/network.dart';
import 'package:slx_snitch/models/value.dart';

class Device extends WappstoModel {
  final String id;
  final String name;
  String manufacturer;
  String product;
  String version;
  String serial;
  String description;
  String protocol;
  String communication;

  List<Value> values = List<Value>();

  Device({this.id, this.name, this.values, Network parent}) : super(parent);

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

  Map<String, dynamic> toJson({bool children = true}) {
    var device = {
      'meta': {
        'id': id,
        'version': '2.0',
        'type': 'device',
      },
      'name': name,
    };

    if(children) {
      List<Map<String, dynamic> > vals = new List<Map<String, dynamic> >();
      values.forEach((val) => vals.add(val.toJson()));
      device['value'] = vals;
    }

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

  Value createNumberValue(String name, String type, double min, double max, double step, String unit) {
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
      List<Value> vals = values.where((val) => val.name == name).toList();
      switch(vals.length) {
        case 0:
        return null;
        case 1:
        return vals[0];
        default:
        List<Value> wrongs = vals.skip(1).toList();
        wrongs.forEach((val) {
            values.remove(val);
            print("Deleting $val");
            val.delete();
        });
        return vals[0];
      }
    }

    return values[0];
  }

  String get url {
    return "${parent.url}/device/$id";
  }

  String toString() {
    return "Device '$name' ($id)";
  }
}
