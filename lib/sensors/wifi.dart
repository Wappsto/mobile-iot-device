import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class WifiSensor extends Sensor {
  WifiSensor() {
    icon = Icons.wifi;
    name = "WiFi Sensor";

    addConfiguration('WiFi', ['WiFi']);
  }

  void onData(ConnectivityResult result) async {
    var data = "";
    if (result == ConnectivityResult.mobile) {
      data = 'Mobile';
    } else if (result == ConnectivityResult.wifi) {
      data = await Connectivity().getWifiName();
    }

    if(update(0, data)) {
      text = "$data";
      call();
    }
  }

  void start() {
    subscription = Connectivity().onConnectivityChanged.listen(onData);
  }

  Value createValue(Device device, String name) {
    Value value = device.createStringValue(name, 'wifi_ssid', 100);
    value.createState(StateType.Report, data: "");
    return value;
  }
}
