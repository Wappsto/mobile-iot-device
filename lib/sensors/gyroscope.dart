import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class GyroscopeSensor extends Sensor {
  GyroscopeSensor() {
    icon = Icons.all_out;
    name = "Gyroscope";
    valueName.add('Gyroscope X');
    valueName.add('Gyroscope Y');
    valueName.add('Gyroscope Z');
  }

  void onData(GyroscopeEvent event) async {
    if(value[0] != null) {
      value[0].update(event.x.toInt().toString());
    }
    if(value[1] != null) {
      value[1].update(event.y.toInt().toString());
    }
    if(value[2] != null) {
      value[2].update(event.z.toInt().toString());
    }

    text = "X: ${event.x.toInt()} Y: ${event.y.toInt()} Z: ${event.z.toInt()}";
    call();
  }

  void start() {
    try {
      subscription = gyroscopeEvents.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'angular_acceleration', 0, 100, 1, 'rad/s^2');
    value.createState(StateType.Report, data: "0");
    value.setDelta(0.5);
    return value;
  }

}
