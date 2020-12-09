import 'package:flutter/material.dart';
import 'package:slx_snitch/models/configuration.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class RunTime extends Configuration {
  RunTime() {
    icon = Icons.access_time;
    name = "Run Time";
    current = "60";

    valueName.add('Run Time');
  }

  void start() {
    text = "Run time: ${current}";
    call();
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'timer', 0, 1000, 1, 'seconds');
    value.createState(StateType.Control, data: current);

    return value;
  }
}
