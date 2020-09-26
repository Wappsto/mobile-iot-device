import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class GyroscopeSensor extends Sensor {
  Value _valueX;
  Value _valueY;
  Value _valueZ;

  GyroscopeSensor() {
    icon = Icons.all_out;
    name = "Gyroscope";
  }

  void onData(GyroscopeEvent event) async {
    if(_valueX != null) {
      _valueX.update(event.x.toInt().toString());
    }
    if(_valueY != null) {
      _valueY.update(event.y.toInt().toString());
    }
    if(_valueZ != null) {
      _valueZ.update(event.z.toInt().toString());
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

  void linkValue(Device device) {
    _valueX = device.findValue(name: 'Gyroscope X');
    if(_valueX == null) {
      _valueX = device.createNumberValue('Gyroscope X', 'velocity_x', 0, 100, 1, 'velocity');
      _valueX.createState(StateType.Report, data: "0");
    }
    _valueY = device.findValue(name: 'Gyroscope Y');
    if(_valueY == null) {
      _valueY = device.createNumberValue('Gyroscope Y', 'velocity_y', 0, 100, 1, 'velocity');
      _valueY.createState(StateType.Report, data: "0");
    }
    _valueZ = device.findValue(name: 'Gyroscope Z');
    if(_valueZ == null) {
      _valueZ = device.createNumberValue('Gyroscope Z', 'velocity_z', 0, 100, 1, 'velocity');
      _valueZ.createState(StateType.Report, data: "0");
    }
  }

}
