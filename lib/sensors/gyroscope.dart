import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class GyroscopeSensor extends Sensor {
  GyroscopeSensor() {
    icon = Icons.all_out;
    name = "Gyroscope";
    addConfiguration(name, [
        'Gyroscope X',
        'Gyroscope Y',
        'Gyroscope Z',
    ]);
  }

  void onData(GyroscopeEvent event) async {
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
    subscription = gyroscopeEvents.listen(onData);
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'angular_acceleration', 0, 100, 1, 'rad/s^2');
    value.createState(StateType.Report, data: "0");
    value.setDelta(0.5);
    return value;
  }

}
