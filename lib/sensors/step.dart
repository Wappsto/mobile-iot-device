import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class StepSensor extends Sensor {
  Value _value;

  StepSensor() {
    icon = Icons.wb_sunny;
    name = "Step Sensor";
  }

  void onData(StepCount step) async {
    print("Step from Step Sensor: ${step.steps}");

    _value.update(step.steps.toString());
    text = step.steps.toString();
    call();
  }

  void start() {
    try {
      subscription = StepRecognition.stepUpdates().listen(onData);
    }
    on Exception catch (exception) {
      print(exception);
    }
  }

  void linkValue(Device device) {
    _value = device.findValue(name: 'Step Sensor');
    if(_value == null) {
      _value = device.createStringValue('Step Sensor', 'Step', 50);
      _value.createState(StateType.Report, data: "");
    }
  }

}
