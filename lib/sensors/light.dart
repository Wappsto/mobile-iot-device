import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class LightSensor extends Sensor {
  Light _light;
  Value _value;

  LightSensor() {
    icon = Icons.wb_sunny;
    name = "Light Sensor";
  }

  void onData(int luxValue) async {
    print("Lux value from Light Sensor: $luxValue");

    if(_value != null) {
      _value.update(luxValue.toString());
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

  void linkValue(Device device) {
    _value = device.findValue(name: 'Light Sensor');
    if(_value == null) {
      _value = device.createNumberValue('Light Sensor', 'Light', 0, 5000, 1, 'lux');
      _value.createState(StateType.Report, data: "0");
    } else {
      _value.setType('Light');
      _value.number['min'] = 0;
      _value.number['max'] = 5000;
      _value.number['step'] = 1;
      _value.number['unit'] = 'lux';
    }
  }

}
