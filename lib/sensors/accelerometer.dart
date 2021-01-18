import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class AccelerometerSensor extends Sensor {
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

  void onData(AccelerometerEvent event) async {
    String timestamp = getTimestamp();
    bool send = false;
    send |= update(0, event.x, timestamp: timestamp);
    send |= update(1, event.y, timestamp: timestamp);
    send |= update(2, event.z, timestamp: timestamp);

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
