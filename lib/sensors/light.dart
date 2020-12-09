import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class LightSensor extends Sensor {
  Light _light;

  LightSensor() {
    icon = Icons.wb_sunny;
    name = "Light Sensor";

    valueName.add('Light');
  }

  void onData(int luxValue) async {
    print("Lux value from Light Sensor: $luxValue");

    if(value[0] != null) {
      value[0].update(luxValue.toString());
    }

    text = "$luxValue lux";
    call();
  }

  void start() {
    _light = new Light();
    try {
      subscription = _light.lightSensorStream.listen(onData);
    }
    on LightException catch (exception) {
      print(exception);
    }
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'illuminance', 0, 100000, 1, 'lx');
    value.createState(StateType.Report, data: "0");
    value.setDelta(10);

    return value;
  }
}
