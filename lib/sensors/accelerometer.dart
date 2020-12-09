import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class AccelerometerSensor extends Sensor {
  AccelerometerSensor() {
    icon = Icons.all_out;
    name = "Accelerometer";
    valueName.add('Accelerometer X');
    valueName.add('Accelerometer Y');
    valueName.add('Accelerometer Z');
  }

  void onData(AccelerometerEvent event) async {
    if(value[0] != null) {
      value[0].update(event.x.toString());
    }
    if(value[1] != null) {
      value[1].update(event.y.toString());
    }
    if(value[2] != null) {
      value[2].update(event.z.toString());
    }

    text = "X: ${event.x.toInt()} Y: ${event.y.toInt()} Z: ${event.z.toInt()}";
    call();
  }

  void start() {
    try {
      subscription = accelerometerEvents.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'acceleration', -1000, 1000, 0.001, 'm/s^2');
    value.createState(StateType.Report, data: "0");
    value.setDelta(0.5);
    return value;
  }

}
