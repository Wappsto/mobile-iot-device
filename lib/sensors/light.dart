import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class LightSensor extends Sensor {
  Light _light = Light();

  LightSensor() {
    icon = Icons.wb_sunny;
    name = "Light Sensor";

    addConfiguration('Light', [
        'Light'
    ]);
  }

  void onData(int luxValue) async {
    if(update(0, luxValue)) {
      text = "$luxValue lux";
      call();
    }
  }

  void start() {
    subscription = _light.lightSensorStream.listen(onData);
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'illuminance', 0, 100000, 1, 'lx');
    value.createState(StateType.Report, data: "0");
    value.setDelta(10);

    return value;
  }
}
