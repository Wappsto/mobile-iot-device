import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';

abstract class Sensor {
  SharedPreferences _prefs;
  StreamSubscription subscription;
  Function _cb;
  String _sensorText = "Tap to enable";
  String name = "";
  List<String> valueName = List<String>();
  List<Value> value = List<Value>();
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

    if(_prefs != null) {
      enabled = _prefs.getBool("${name}_enabled");
      if(enabled == null) {
        enabled = false;
      }

      if(enabled) {
        _sensorText = "Loading...";
      }
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
    if(_prefs != null) {
      _prefs.setBool("${name}_enabled", enabled);
    }

    if(enabled) {
      start();
    } else {
      stop();
    }
  }

  void toggleEnabled() {
    this.enable = !this.enabled;
  }

  void linkValue(Device device, bool create) {
    valueName.forEach((n) {
        Value val = device.findValue(name: n);
        if(val == null) {
          if(create) {
            val = createValue(device, n);
          } else {
            print("Do not enable $n");
          }
        }
        value.add(val);
    });
  }

  void start();
  Value createValue(Device device, String name);
}
