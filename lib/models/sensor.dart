import 'package:flutter/material.dart';
import 'dart:async';
import 'device.dart';

abstract class Sensor {
  StreamSubscription _subscription;
  Function _cb;
  String _sensorText = "";
  String _name = "";
  IconData _icon;

  StreamSubscription get subscription {
    return _subscription;
  }

  void set subscription(StreamSubscription sub) {
    _subscription = sub;
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

  void setCallback(Function cb) {
    _cb = cb;
  }

  void call() {
    if(_cb != null) {
      _cb();
    }
  }

  void set text(String txt) {
    _sensorText = txt;
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

  String toString() {
    return _sensorText;
  }

  void start();
  void linkValue(Device device);
}
