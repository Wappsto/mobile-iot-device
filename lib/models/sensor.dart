import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:mobile_iot_device/models/device.dart';

abstract class Sensor {
  SharedPreferences _prefs;
  StreamSubscription _subscription;
  Function _cb;
  String _sensorText = "Idle";
  String _name = "";
  IconData _icon;
  bool _enabled = true;

  StreamSubscription get subscription {
    return _subscription;
  }

  void set subscription(StreamSubscription sub) {
    _subscription = sub;
  }

  void run() {
    if(_enabled) {
      start();
    }
  }

  void stop() {
    try {
      if (_subscription != null) {
        _subscription.cancel();
        _subscription = null;
      }
    } catch (err) {
      print('Sensor stop error: $err');
    }
  }

  void setup(Function cb, SharedPreferences prefs) {
    _cb = cb;
    _prefs = prefs;

    _enabled = _prefs.getBool("${name}_enabled");
    if(_enabled == null) {
      _enabled = false;
    }
  }

  void call() {
    if(_cb != null) {
      _cb();
    }
  }

  void set text(String txt) {
    _sensorText = txt;
  }

  String toString() {
    return _sensorText;
  }

  void set icon(IconData icon) {
    _icon = icon;
  }

  IconData get icon {
    return _icon;
  }

  void set name(String name) {
    _name = name;
  }

  String get name {
    return _name;
  }

  void set enabled(bool enabled) {
    if(_enabled == enabled) {
      return;
    }

    _enabled = enabled;
    _prefs.setBool("${name}_enabled", _enabled);

    if(_enabled) {
      start();
    } else {
      stop();
    }
  }

  bool get enabled {
    return _enabled;
  }

  void toggleEnabled() {
    print("Toggle ${_enabled}");
    enabled = !_enabled;
    print("Toggle ${_enabled}");
  }

  void start();
  void linkValue(Device device);
}
