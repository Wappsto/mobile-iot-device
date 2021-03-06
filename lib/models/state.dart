import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/wappsto_model.dart';
import 'package:slx_snitch/utils/timestamp.dart';

enum StateType {
  Report,
  Control
}

class State extends WappstoModel {
  final String id;
  final StateType type;
  String _type;
  String data;
  String timestamp;

  State({this.id, this.type, this.timestamp, this.data, Value parent}) : super(parent) {
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

  void update(String newData, {String timestamp}) {
    data = newData;
    this.timestamp = timestamp == null ? timestamp : getISOTimestamp();
  }

  Map<String, dynamic> toJson({bool children = true}) {
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

  String get url {
    return "${parent.url}/state/$id";
  }

  String toString() {
    return "State '$type' ($id)";
  }
}
