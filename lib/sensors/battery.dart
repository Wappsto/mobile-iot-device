import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/iso_battery_info.dart';

import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class BatterySensor extends Sensor {
  BatteryInfoPlugin _battery = BatteryInfoPlugin();
  Value _value;

  BatterySensor() {
    icon = Icons.battery_charging_full;
    name = "Battery Sensor";
  }

  void onData(IosBatteryInfo info) async {
    print("Battery value: ${info.batteryLevel}");

    if(_value != null) {
      _value.update(info.batteryLevel.toString());
    }

    text = "${info.batteryLevel} %";
    call();
  }

  void start() {
    try {
      subscription = _battery.iosBatteryInfoStream.listen(onData);
    }
    catch (exception) {
      print(exception);
    }
  }

  void linkValue(Device device) {
    _value = device.findValue(name: 'Battery Sensor');
    if(_value == null) {
      _value = device.createNumberValue('Battery', 'battery_level', 0, 100, 1, '%');
      _value.createState(StateType.Report, data: "0");
    }

    _value.setDelta(1);
  }

}
