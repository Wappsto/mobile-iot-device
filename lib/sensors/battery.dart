import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/iso_battery_info.dart';

import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class BatterySensor extends Sensor {
  BatteryInfoPlugin _battery = BatteryInfoPlugin();

  BatterySensor() {
    icon = Icons.battery_charging_full;
    name = "Battery Sensor";

    addConfiguration('Battery', ['Battery']);
  }

  void onData(IosBatteryInfo info) async {
    if(update(0, info.batteryLevel)) {
      text = "${info.batteryLevel} %";
      call();
    }
  }

  void start() {
    subscription = _battery.iosBatteryInfoStream.listen(onData);
  }

  Value createValue(Device device, String name) {
    Value value = device.createNumberValue(name, 'battery_level', 0, 100, 1, '%');
    value.createState(StateType.Report, data: "0");
    value.setDelta(1);
    return value;
  }
}
