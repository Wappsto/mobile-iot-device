import 'package:mobile_iot_device/models/value.dart';
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
  Value parent;

  State({this.id, this.type, this.timestamp, this.data, this.parent}) {
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
    data = newData;
    timestamp = DateTime.now().toUtc().toIso8601String();
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
    return "${parent.url}/state/$id";
  }

  String toString() {
    return "State '$type' ($id)";
  }
}
