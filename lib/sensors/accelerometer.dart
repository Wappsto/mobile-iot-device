import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class AccelerometerSensor extends Sensor {
  int last = 0;
  int diff = 0;
  int min = 0;
  int max = 0;

  AccelerometerSensor() {
    icon = Icons.all_out;
    name = "Accelerometer";

    addConfiguration(name, [
        'Accelerometer X',
        'Accelerometer Y',
        'Accelerometer Z'
      ]
    );
  }

  void toCSV(AccelerometerEvent event) {
    DateTime now = DateTime.now();
    int ticks = now.microsecondsSinceEpoch;
    if(last == 0) {
      last = ticks;
    }
    print("${ticks - last},${event.x},${event.y},${event.z}");
  }

  void onData(AccelerometerEvent event) async {
    String timestamp = getTimestamp();
    bool send = false;
    send |= update(0, event.x, timestamp: timestamp);
    send |= update(1, event.y, timestamp: timestamp);
    send |= update(2, event.z, timestamp: timestamp);

    //toCSV(event);

    if(send) {
      text = "X: ${event.x.toInt()} Y: ${event.y.toInt()} Z: ${event.z.toInt()}";
      call();
    }
  }

  void start() {
    subscription = accelerometerEvents.listen(onData);
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'acceleration', -1000, 1000, 0.001, 'm/s^2');
    value.createState(StateType.Report, data: "0");
    value.setDelta(0.5);
    return value;
  }
}
