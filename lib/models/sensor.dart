import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:mobile_iot_device/models/device.dart';

abstract class Sensor {
  SharedPreferences _prefs;
  StreamSubscription subscription;
  Function _cb;
  String _sensorText = "Idle";
  String name = "";
  IconData icon;
  bool enabled = true;

  void run() {
    if(enabled) {
      start();
    }
  }

  void stop() {
    try {
      if (subscription != null) {
        subscription.cancel();
        subscription = null;
      }
    } catch (err) {
      print('Sensor stop error: $err');
    }
  }

  void setup(Function cb, SharedPreferences prefs) {
    _cb = cb;
    _prefs = prefs;

    enabled = _prefs.getBool("${name}_enabled");
    if(enabled == null) {
      enabled = false;
    }
  }

  void call() {
    if(_cb != null) {
      _cb();
    }
  }

  set text(String txt) {
    _sensorText = txt;
  }

  String toString() {
    return _sensorText;
  }

  set enable(bool enabled) {
    if(this.enabled == enabled) {
      return;
    }

    this.enabled = enabled;
    _prefs.setBool("${name}_enabled", enabled);

    if(enabled) {
      start();
    } else {
      stop();
    }
  }

  void toggleEnabled() {
    this.enable = !this.enabled;
  }

  void start();
  void linkValue(Device device);
}
