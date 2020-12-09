import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class CompassSensor extends Sensor {
  final List<String> _headings = [
    'N', 'NNE', 'NE', 'ENE',
    'E','ESE','SE', 'SSE',
    'S', 'SSW','SW', 'WSW',
    'W', 'WNW','NW', 'NNW',
    'N'];

  CompassSensor() {
    icon = Icons.stars;
    name = "Compass Sensor";
    valueName.add('Compass Sensor');
    valueName.add('Compass');
  }

  void onData(double compassValue) async {
    int cv = compassValue.toInt();
    String dir = "";

    dir = _headings[(compassValue + 11.25) ~/ 22.5];

    if(value[0] != null) {
      value[0].update(cv.toString());
    }

    if(value[1] != null) {
      value[1].update(dir);
    }

    print("Compass value : $dir ($cv)");
    text = "$dir ($cv °)";
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

  Value createValue(Device device, String name) {
    Value v;
    if(name == "Compass") {
      v = device.createStringValue('Compass', 'bearing', 3);
      v.createState(StateType.Report, data: "N");
    } else {
      v = device.createNumberValue('Compass Sensor', 'angle', 0, 360, 1, '°');
      v.createState(StateType.Report, data: "0");
      v.setDelta(5);
    }
    return v;
  }
}
