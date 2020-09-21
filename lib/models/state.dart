import 'value.dart';
import 'dart:convert';

enum StateType {
  Report,
  Control
}

class State {
  final String id;
  final StateType type;
  String _type;
  String data;
  String timestamp;
  DateTime last_update;
  Value parent;
  bool increace_update = false;

  State({this.id, this.type, this.timestamp, this.data, this.parent = null}) {
    _type = type == StateType.Report ? "Report" : "Control";
    if(timestamp == null) {
      timestamp = new DateTime.now().toUtc().toIso8601String();
    }
  }

  factory State.fromJson(Map<String, dynamic> json, Value parent) {
    return State(
      id: json['meta']['id'],
      type: json['type'] == 'Report' ? StateType.Report : StateType.Control,
      timestamp: json['timestamp'],
      data: json['data'],
      parent: parent,
    );
  }

  void update(String newData) {
    var tmp = DateTime.now();
    bool forceUpdate = false;
    if(increace_update && int.parse(newData) > int.parse(data)) {
      forceUpdate = true;
    }
    data = newData;
    timestamp = tmp.toUtc().toIso8601String();

    if(forceUpdate || last_update == null || tmp.difference(last_update).inMinutes >= 1) {
      parent.wappsto.updateState(this);
      last_update = tmp;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': {
        'id': id,
        'version': '2.0',
        'type': 'state',
      },
      'type': _type,
      'timestamp': timestamp,
      'data': data,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  String get url {
    return "${parent.url}/state/${id}";
  }

  String toString() {
    return "State '${type}' (${id})";
  }
}
