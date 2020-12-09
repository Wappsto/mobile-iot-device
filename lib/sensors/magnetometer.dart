import 'package:flutter/material.dart';
import 'package:flutter_magnetometer/flutter_magnetometer.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class MagnetometerSensor extends Sensor {
  MagnetometerSensor() {
    icon = Icons.all_out;
    name = "Magnetometer";
    valueName.add('Magnetometer X');
    valueName.add('Magnetometer Y');
    valueName.add('Magnetometer Z');
  }

  void onData(MagnetometerData event) async {
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
      subscription = FlutterMagnetometer.events.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'magnetic_flux_density', -1000, 1000, 0.001, 'µT');
    value.createState(StateType.Report, data: "0");
    value.setDelta(0.5);
    return value;
  }

}
