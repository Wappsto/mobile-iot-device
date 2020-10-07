import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class AccelerometerSensor extends Sensor {
  Value _valueX;
  Value _valueY;
  Value _valueZ;

  AccelerometerSensor() {
    icon = Icons.all_out;
    name = "Accelerometer";
  }

  void onData(AccelerometerEvent event) async {
    if(_valueX != null) {
      _valueX.update(event.x.toString());
    }
    if(_valueY != null) {
      _valueY.update(event.y.toString());
    }
    if(_valueZ != null) {
      _valueZ.update(event.z.toString());
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

  void linkValue(Device device) {
    _valueX = device.findValue(name: 'Accelerometer X');
    if(_valueX == null) {
      _valueX = device.createNumberValue('Accelerometer X', 'acceleration', -1000, 1000, 0.001, 'm/s^2');
      _valueX.createState(StateType.Report, data: "0");
    }
    _valueY = device.findValue(name: 'Accelerometer Y');
    if(_valueY == null) {
      _valueY = device.createNumberValue('Accelerometer Y', 'acceleration', -1000, 1000, 0.001, 'm/s^2');
      _valueY.createState(StateType.Report, data: "0");
    }
    _valueZ = device.findValue(name: 'Accelerometer Z');
    if(_valueZ == null) {
      _valueZ = device.createNumberValue('Accelerometer Z', 'acceleration', -1000, 1000, 0.001, 'm/s^2');
      _valueZ.createState(StateType.Report, data: "0");
    }

    _valueX.setDelta(0.5);
    _valueY.setDelta(0.5);
    _valueZ.setDelta(0.5);
  }

}
