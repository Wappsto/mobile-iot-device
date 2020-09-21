import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'models/sensor.dart';
import 'models/device.dart';
import 'models/value.dart';
import 'models/state.dart';

class ActivitySensor extends Sensor {
  Value _value;

  ActivitySensor() {
    icon = Icons.wb_sunny;
    name = "Activity Sensor";
  }

  void onData(Activity activity) async {
    print("Activity from Activity Sensor: $activity");

    _value.update(activity.type.toString());
    text = "$activity.type";
    call();
  }

  void start() {
    try {
      subscription = ActivityRecognition.activityUpdates().listen(onData);
    }
    on Exception catch (exception) {
      print(exception);
    }
  }

  void linkValue(Device device) {
    _value = device.findValue(name: 'Activity Sensor');
    if(_value == null) {
      _value = device.createStringValue('Activity Sensor', 'Activity', 50);
      _value.createState(StateType.Report, data: "");
    }
  }

}
