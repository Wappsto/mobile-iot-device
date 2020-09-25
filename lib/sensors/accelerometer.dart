import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'models/sensor.dart';
import 'models/device.dart';
import 'models/value.dart';
import 'models/state.dart';

class AccelerometerSensor extends Sensor {
  Value _valueX;
  Value _valueY;
  Value _valueZ;

  AccelerometerSensor() {
    icon = Icons.all_out;
    name = "Accelerometer";
  }

  void onData(AccelerometerEvent event) async {

    //print("Accelerometer Event: $event");

    _valueX.update(event.x.toInt().toString());
    _valueY.update(event.y.toInt().toString());
    _valueZ.update(event.z.toInt().toString());

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

  void linkValue(Device device) {
    _valueX = device.findValue(name: 'Accelerometer X');
    if(_valueX == null) {
      _valueX = device.createNumberValue('Accelerometer X', 'velocity_x', -100, 100, 1, 'velocity');
      _valueX.createState(StateType.Report, data: "0");
    }
    _valueY = device.findValue(name: 'Accelerometer Y');
    if(_valueY == null) {
      _valueY = device.createNumberValue('Accelerometer Y', 'velocity_y', -100, 100, 1, 'velocity');
      _valueY.createState(StateType.Report, data: "0");
    }
    _valueZ = device.findValue(name: 'Accelerometer Z');
    if(_valueZ == null) {
      _valueZ = device.createNumberValue('Accelerometer Z', 'velocity_z', -100, 100, 1, 'velocity');
      _valueZ.createState(StateType.Report, data: "0");
    }
  }

}
