import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/value.dart';

class ConfigurationItem {
  SharedPreferences _prefs;
  List<String> _names = List<String>();
  List<Value> _values = List<Value>();
  final String name;
  final Sensor sensor;
  bool enabled = false;

  ConfigurationItem(this.name, this.sensor);

  void setup(SharedPreferences prefs) {
    _prefs = prefs;
    if(_prefs != null) {
      enabled = _prefs.getBool("${name}_enabled");
    }
    if(enabled == null) {
      enabled = false;
    }
  }

  void addValueName(String name) {
    _names.add(name);
  }

  void addValue(Value value) {
    if(value == null) {
      print("Tried to add NULL value to configuration $name");
      return;
    }

    _names.forEach((name) {
      if(name == value.name) {
        _values.add(value);
      }
    });
  }

  List<Widget> _getSingleValueWidgets(Sensor sensor, Value value) {
    List<Widget> widgets = List<Widget>();

    double period = 0.0;
    if(value.period != null) {
      period = value.period;
    }

    if(value.number != null) {
      double min = 0.0;
      double max = value.number['max'].toDouble();
      double step = value.number['step'].toDouble();
      double delta = 0.0;
      if(value.delta != null) {
        delta = value.delta.toDouble();
      }

      double deltaStep = delta / 50;
      if(deltaStep > 0) {
        max = delta + (deltaStep * 50);
        min = delta - (deltaStep * 50);
      }

      if(min < 0.0) {
        min = 0;
      }

      widgets.add(SliderSettingsTile(
          title: 'Minimum change that triggers an update',
          settingKey: '$name|delta',
          defaultValue: delta,
          min: min,
          max: max,
          step: step,
          leading: Icon(Icons.trending_up),
          onChange: (value) {
            _values.forEach((val) {
                val.delta = value;
                val.save();
            });
            sensor.save();
          },
        ),
      );
    }

    widgets.add(SliderSettingsTile(
        title: 'Minimum seconds between 2 updates',
        settingKey: '$name|period',
        defaultValue: period,
        min: 0,
        max: 120,
        step: 1,
        leading: Icon(Icons.update),
        onChange: (value) {
          _values.forEach((val) {
              val.period = value;
              val.save();
          });
          sensor.save();
        },
      ),
    );

    return widgets;
  }

  List<Widget> getWidgets() {
    List<Widget> children = List<Widget>();

    children.add(SwitchSettingsTile(
        settingKey: '$name|enable',
        title: 'Enable $name',
        enabledLabel: 'Enabled',
        disabledLabel: 'Disabled',
        defaultValue: enabled,
        leading: Icon(sensor.icon),
        childrenIfEnabled: _getSingleValueWidgets(sensor, _values[0]),
        onChange: (value) {
          if(value != enabled) {
            enabled = value;
            if(_prefs != null) {
              _prefs.setBool("${name}_enabled", value);
            }
            sensor.updateEnabled();
            sensor.save();
          }
        },
    ));

    return children;
  }

}
