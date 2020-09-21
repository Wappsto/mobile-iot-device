import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'models/sensor.dart';
import 'models/device.dart';
import 'models/value.dart';
import 'models/state.dart';

class WifiSensor extends Sensor {
  Value _value;

  WifiSensor() {
    icon = Icons.wifi;
    name = "WiFi Sensor";
  }

  void onData(ConnectivityResult result) async {
    var data = "";
    if (result == ConnectivityResult.mobile) {
      data = 'Mobile';
    } else if (result == ConnectivityResult.wifi) {
      data = await Connectivity().getWifiName();
    }

    _value.update(data);
    text = "$data";
    call();
  }

  void start() {
    subscription = Connectivity().onConnectivityChanged.listen(onData);
  }

  void linkValue(Device device) {
    _value = device.findValue(name: 'WiFi Sensor');
    if(_value == null) {
      _value = device.createStringValue('WiFi Sensor', 'WiFi SSID', 100);
      _value.createState(StateType.Report, data: "");
    }
  }
}
