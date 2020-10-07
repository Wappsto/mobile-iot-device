import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class CompassSensor extends Sensor {
  Value _value;

  CompassSensor() {
    icon = Icons.all_out; //Icons.compass_calibration;
    name = "Compass Sensor";
  }

  void onData(double compassValue) async {
    print("Compass value : $compassValue");

    if(_value != null) {
      _value.update(compassValue.toString());
    }

    text = "$compassValue degress";
    call();
  }

  void start() {
    try {
      subscription = FlutterCompass.events.listen(onData);
    }
    catch (exception) {
      print(exception);
    }
  }

  void linkValue(Device device) {
    _value = device.findValue(name: 'Compass Sensor');
    if(_value == null) {
      _value = device.createNumberValue('Compass Sensor', 'Compass', 0, 360, 1, 'degree');
      _value.createState(StateType.Report, data: "0");
    }
  }

}
