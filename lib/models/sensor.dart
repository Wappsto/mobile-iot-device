import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:slx_snitch/configuration_item.dart';
import 'package:slx_snitch/manager.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/utils/timestamp.dart';

abstract class Sensor {
  StreamSubscription subscription;
  Manager _manager;
  Function _cb;
  String _sensorText = "Click to Configure";
  String name = "";
  List<String> _valueName = List<String>();
  List<Value> value = List<Value>();
  List<ConfigurationItem> _configuration = List<ConfigurationItem>();
  IconData icon;

  void addValue(String name) {
    _valueName.add(name);
  }

  void addConfiguration(String name, List<String> values) {
    ConfigurationItem conf = ConfigurationItem(name, this);

    values.forEach((val) {
        addValue(val);
        conf.addValueName(val);
    });

    _configuration.add(conf);
  }

  List<Widget> getConfiguration() {
    List<Widget> widgets = List<Widget>();
    _configuration.forEach((conf) {
        widgets.addAll(conf.getWidgets());
    });
    return widgets;
  }

  bool run() {
    if(enabled) {
      try {
        start();
        return true;
      } catch (exception, backtrace) {
        print("Failed to start $name");
        print(exception);
        print(backtrace);
      }
    }

    return false;
  }

  void stop() {
    try {
      if (subscription != null) {
        subscription.cancel();
        subscription = null;
      }
    } catch (err) {
      print('$name stop error: $err');
    }
  }

  void setup(Manager manager, Function cb, SharedPreferences prefs) {
    _manager = manager;
    _cb = cb;

    _configuration.forEach((conf) {
        conf.setup(prefs);
    });

    if(enabled) {
      _sensorText = "Loading...";
    }
  }

  bool update(int index, var data, {String timestamp}) {
    bool res = false;
    value.forEach((val) {
        if(val != null &&
          val.name == _valueName[index]) {
          res = val.update(data.toString(), timestamp: timestamp);
        }
    });

    return res;
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

  get enabled {
    if(_configuration.length == 0) {
      return true;
    }
    bool res = false;
    _configuration.forEach((conf) {
        if(conf.enabled) {
          res = true;
        }
    });
    return res;
  }

  void updateEnabled() {
    if(enabled) {
      if(!run()) {
        stop();
      }
    } else {
      stop();
    }
  }

  void save() {
    _manager.saveNetwork();
  }

  void linkValue(Device device, bool create) {
    _valueName.forEach((n) {
        Value val = device.findValue(name: n);
        if(val == null) {
          if(create) {
            val = createValue(device, n);
          } else {
            _configuration.forEach((conf) {
                conf.enabled = false;
            });
            print("Do not enable $n");
          }
        } else if(!create) {
          _configuration.forEach((conf) {
              conf.enabled = true;
          });
        }
        value.add(val);
        _configuration.forEach((conf) {
            conf.addValue(val);
        });
    });
  }

  Value getValue(String name) {
    return value.firstWhere((val) => val.name == name);
  }

  String getTimestamp() {
    return getISOTimestamp();
  }

  void start();
  Value createValue(Device device, String name);
}
