import 'package:uuid/uuid.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/state.dart';
import 'package:slx_snitch/wappsto.dart';

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
  int period;
  double delta;

  Map<String, dynamic> number;
  Map<String, dynamic> string;

  Device parent;
  List<State> states;

  DateTime lastUpdate;

  Value({this.id, this.name, this.type, this.permission, String period, String delta, this.states, this.parent}) {
    states = new List<State>();

    if(period != null) {
      try {
        this.period = int.parse(period);
      } catch(e) {
        print("Failed to parse period ($period) for $name");
      }
    } else {
      this.period = 60;
    }

    if(delta != null) {
      try {
        this.delta = double.parse(delta);
      } catch(e) {
        print("Failed to parse delta ($delta) for $name");
      }
    }

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
      period: json['period'],
      delta: json['delta'],
      states: new List<State>(),
      parent: parent,
    );

    json['state'].forEach((state) {
        if(state is Map<String, dynamic>) {
          value.states.add(State.fromJson(state, value));
        }
    });

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

    if(period != null) {
      val['period'] = period.toString();
    }

    if(delta != null) {
      val['delta'] = delta.toString();
    }

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

  bool update(String newData) {
    State state = states.singleWhere((s) => s.type == StateType.Report, orElse: () => null);
    if(state != null) {
      var tmp = DateTime.now();
      bool deltaUpdate = false;
      bool periodUpdate = false;

      try {
        if(delta != null) {
          if((double.parse(newData) - double.parse(state.data)).abs() >= delta) {
            print("Delta update: ${(double.parse(newData) - double.parse(state.data)).abs()} >= $delta");
            deltaUpdate = true;
          }
        } else if(newData != state.data) {
          deltaUpdate = true;
        }
      } catch(e) {
        print("Failed to convert $newData or ${state.data} to int ($delta)");
        print(e);
      }

      try {
        if(lastUpdate == null || (period != null && tmp.difference(lastUpdate).inSeconds >= period)) {
          periodUpdate = true;
        }
      } catch(e) {
        print("Failed to check $lastUpdate or $period");
        print(e);
      }

      state.update(newData);

      if(deltaUpdate || periodUpdate) {
        print("Updating $name with $newData (${lastUpdate == null} $deltaUpdate $periodUpdate)");
        wappsto.updateState(state);
        lastUpdate = tmp;
        return true;
      }
    } else {
      print("Failed to find report state for $name");
    }

    return false;
  }

  bool delete() {
    wappsto.deleteValue(this);
  }

  Wappsto get wappsto {
    return parent.wappsto;
  }

  String get url {
    return "${parent.url}/value/$id";
  }

  void setType(String type) {
    this.type = type;
  }

  void setDelta(double delta) {
    this.delta = delta;
  }

  void setPeriod(int period) {
    this.period = period;
  }

  String toString() {
    if(number != null) {
      return "Number Value '$name' ($id)";
    } else if(string != null) {
      return "String Value '$name' ($id)";
    }

    return "Unknown Value  '$name' ($id)";
  }
}
