import 'package:uuid/uuid.dart';
import 'package:slx_snitch/models/wappsto_model.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/state.dart';

enum ValuePermission {
  ReadOnly,
  WriteOnly,
  ReadWrite
}

class Value extends WappstoModel {
  final String id;
  final String name;
  String type;
  ValuePermission permission;
  String _permission;
  double period;
  double delta;

  Map<String, dynamic> number;
  Map<String, dynamic> string;
  Map<String, dynamic> blob;

  List<State> states = List<State>();

  DateTime lastUpdate;

  Value({this.id, this.name, this.type, this.permission, String period, String delta, this.states, Device parent}) : super(parent) {
    if(period != null) {
      try {
        this.period = double.parse(period);
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

    if(states == null) {
      states = List<State>();
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
    } else if(json['blob'] != null) {
      value.blob = json['blob'];
    }

    return value;
  }

  Map<String, dynamic> toJson({bool children = true}) {
    var val = {
      'meta': {
        'id': id,
        'version': '2.0',
        'type': 'value',
      },
      'name': name,
      'type': type,
      'permission': _permission,
    };

    if(children) {
      List<Map<String, dynamic> > stas = new List<Map<String, dynamic> >();
      states.forEach((state) => stas.add(state.toJson()));
      val['state'] = stas;
    }

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
    } else if(blob != null) {
      val['blob'] = blob;
    }

    return val;
  }

  void setType(String type) {
    this.type = type;
  }

  void setDelta(double delta) {
    this.delta = delta;
  }

  void setPeriod(double period) {
    this.period = period;
  }

  void createNumber(double min, double max, double step, String unit) {
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

  void createBlob(int max) {
    blob = {
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
        print("Failed to convert $newData or ${state.data} to double ($delta)");
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
        print("Updating $name ($id) with $newData (${lastUpdate == null} $deltaUpdate $periodUpdate)");
        state.save();
        lastUpdate = tmp;
        return true;
      }
    } else {
      print("Failed to find report state for $name");
    }

    return false;
  }

  String get url {
    return "${parent.url}/value/$id";
  }

  String toString() {
    if(number != null) {
      return "Number Value '$name' ($id)";
    } else if(string != null) {
      return "String Value '$name' ($id)";
    } else if(blob != null) {
      return "Blob Value '$name' ($id)";
    }

    return "Unknown Value  '$name' ($id)";
  }
}
