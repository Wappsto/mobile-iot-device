import 'package:uuid/uuid.dart';
import 'device.dart';
import 'state.dart';
import '../wappsto.dart';

enum ValuePermission {
  ReadOnly,
  WriteOnly,
  ReadWrite
}

class Value {
  final String id;
  final String name;
  String type;
  ValuePermission permission;
  String _permission;
  Map<String, dynamic> number = null;
  Map<String, dynamic> string = null;

  Device parent;
  List<State> states;

  Value({this.id, this.name, this.type, this.permission, this.states = null, this.parent = null}) {
    states = new List<State>();

    switch(permission) {
      case ValuePermission.ReadOnly: {
        _permission = "r";
      }
      break;
      case ValuePermission.WriteOnly: {
        _permission = "w";
      }
      break;
      default: {
        _permission = "rw";
      }
    }
  }

  factory Value.fromJson(Map<String, dynamic> json, Device parent) {
    ValuePermission per;
    switch(json['permission']) {
      case 'rw': {
        per = ValuePermission.ReadWrite;
      }
      break;
      case 'r': {
        per = ValuePermission.ReadOnly;
      }
      break;
      case 'w': {
        per = ValuePermission.WriteOnly;
      }
      break;
    }

    Value value = Value(
      id: json['meta']['id'],
      name: json['name'],
      type: json['type'],
      permission: per,
      states: new List<State>(),
      parent: parent,
    );

    json['state'].forEach((state) => value.states.add(State.fromJson(state, value)));

    if(json['number'] != null) {
      value.number = json['number'];
    } else if(json['string'] != null) {
      value.string = json['string'];
    }

    return value;
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic> > stas = new List<Map<String, dynamic> >();
    states.forEach((state) => stas.add(state.toJson()));

    var val = {
      'meta': {
        'id': id,
        'version': '2.0',
        'type': 'value',
      },
      'name': name,
      'type': type,
      'permission': _permission,
      'state': stas,
    };

    if(number != null) {
      val['number'] = number;
    } else if(string != null) {
      val['string'] = string;
    }

    return val;
  }

  void createNumber(int min, int max, double step, String unit) {
    number = {
      'min': min,
      'max': max,
      'step': step,
      'unit': unit,
    };
  }

  void createString(int max) {
    string = {
      'max': max,
    };
  }

  State createState(StateType type, {String timestamp, String data}) {
    Uuid uuid = Uuid();
    State state = new State(id: uuid.v4(), type: type, timestamp: timestamp, data: data);
    state.parent = this;

    states.add(state);

    return state;
  }

  void update(String newData) {
    State state = states.singleWhere((s) => s.type == StateType.Report, orElse: () => null);
    if(state != null) {
      print("Updating $name with $newData");
      state.update(newData);
    } else {
      print("Failed to find report state for $name");
    }
  }

  Wappsto get wappsto {
    return parent.wappsto;
  }

  String get url {
    return "${parent.url}/value/${id}";
  }

  void setType(String type) {
    this.type = type;
  }

  String toString() {
    if(number != null) {
      return "Number Value '${name}' (${id})";
    } else if(string != null) {
      return "String Value '${name}' (${id})";
    }

    return "Unknown Value  '${name}' (${id})";
  }
}
