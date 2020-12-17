import 'package:flutter/material.dart';
//import 'package:flutter_magnetometer/flutter_magnetometer.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class MagnetometerSensor extends Sensor {
  MagnetometerSensor() {
    icon = Icons.all_out;
    name = "Magnetometer";

    addConfiguration(name, [
        'Magnetometer X',
        'Magnetometer Y',
        'Magnetometer Z'
    ]);
  }

  /*void onData(MagnetometerData event) async {
    update(0, event.x);
    update(1, event.y);
    update(2, event.z);

    text = "X: ${event.x.toInt()} Y: ${event.y.toInt()} Z: ${event.z.toInt()}";
    call();
  }*/

  void start() {
    //subscription = FlutterMagnetometer.events.listen(onData);
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'magnetic_flux_density', -1000, 1000, 0.001, 'µT');
    value.createState(StateType.Report, data: "0");
    value.setDelta(0.5);
    return value;
  }

}
