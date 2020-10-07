import 'package:flutter/material.dart';
import 'package:flutter_magnetometer/flutter_magnetometer.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class MagnetometerSensor extends Sensor {
  Value _valueX;
  Value _valueY;
  Value _valueZ;

  MagnetometerSensor() {
    icon = Icons.all_out;
    name = "Magnetometer";
  }

  void onData(MagnetometerData event) async {
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
      subscription = FlutterMagnetometer.events.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  void linkValue(Device device) {
    _valueX = device.findValue(name: 'Magnetometer X');
    if(_valueX == null) {
      _valueX = device.createNumberValue('Magnetometer X', 'magnetic_flux_density', -1000, 1000, 0.001, 'µT');
      _valueX.createState(StateType.Report, data: "0");
    }
    _valueY = device.findValue(name: 'Magnetometer Y');
    if(_valueY == null) {
      _valueY = device.createNumberValue('Magnetometer Y', 'magnetic_flux_density', -1000, 1000, 0.001, 'µT');
      _valueY.createState(StateType.Report, data: "0");
    }
    _valueZ = device.findValue(name: 'Magnetometer Z');
    if(_valueZ == null) {
      _valueZ = device.createNumberValue('Magnetometer Z', 'magnetic_flux_density', -1000, 1000, 0.001, 'µT');
      _valueZ.createState(StateType.Report, data: "0");
    }

    _valueX.setDelta(0.5);
    _valueY.setDelta(0.5);
    _valueZ.setDelta(0.5);
  }

}
