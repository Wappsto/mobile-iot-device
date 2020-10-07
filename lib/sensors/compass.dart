import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class CompassSensor extends Sensor {
  Value _value;
  Value _valueBearing;
  final List<String> _headings = [
    'N', 'NNE', 'NE', 'ENE',
    'E','ESE','SE', 'SSE',
    'S', 'SSW','SW', 'WSW',
    'W', 'WNW','NW', 'NNW',
    'N'];

  CompassSensor() {
    icon = Icons.stars;
    name = "Compass Sensor";
  }

  void onData(double compassValue) async {
    int value = compassValue.toInt();
    String dir = "";

    dir = _headings[((compassValue + 11.25) / 22.5).toInt()];

    if(_value != null) {
      _value.update(value.toString());
    }

    if(_valueBearing != null) {
      _valueBearing.update(dir);
    }

    print("Compass value : $dir ($value)");
    text = "$dir ($value °)";
    call();
  }

  void start() {
    print("Start compass");
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
      _value = device.createNumberValue('Compass Sensor', 'angle', 0, 360, 1, '°');
      _value.createState(StateType.Report, data: "0");
    }

    _valueBearing = device.findValue(name: 'Compass');
    if(_valueBearing == null) {
      _valueBearing = device.createStringValue('Compass', 'bearing', 3);
      _valueBearing.createState(StateType.Report, data: "N");
    }

    _value.setDelta(5);
  }

}
