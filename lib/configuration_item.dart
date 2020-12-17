import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:slx_snitch/manager.dart';
import 'package:slx_snitch/utils/cache_provider.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/screens/configure_value.dart';

class ConfigurationItem {
  List<String> _names = List<String>();
  List<Value> _values = List<Value>();
  final String name;
  final Sensor sensor;

  ConfigurationItem(this.name, this.sensor);

  void addValueName(String name) {
    _names.add(name);
  }

  void addValue(Value value) {
    _names.forEach((name) {
      if(name == value.name) {
        _values.add(value);
      }
    });
  }

  List<Widget> _getSingleValueWidgets(Sensor sensor, Value value) {
    List<Widget> widgets = List<Widget>();

    if(value.number != null) {
      double min = value.number['min'].toDouble();
      double max = value.number['max'].toDouble();
      double step = value.number['step'].toDouble();
      double delta = 0.0;
      if(value.delta != null) {
        delta = value.delta.toDouble();
      }

      widgets.add(SliderSettingsTile(
          title: 'Minimum change that triggers an update',
          settingKey: '${sensor.name}|${value.name}|delta',
          defaultValue: delta,
          min: min,
          max: max,
          step: step,
          leading: Icon(Icons.trending_up),
          onChange: (value) {
            _values.forEach((val) {
                val.delta = value;
            });

          },
        ),
      );
    }

    widgets.add(SliderSettingsTile(
        title: 'Minimum time between 2 updates',
        settingKey: '${sensor.name}|${value.name}|period',
        defaultValue: 0,
        min: 0,
        max: 120,
        step: 1,
        leading: Icon(Icons.update),
        onChange: (value) {
          debugPrint('key-slider-volume: $value');
        },
      ),
    );

    return widgets;
  }

  List<Widget> getWidgets() {
    List<Widget> children = List<Widget>();

    children.add(SwitchSettingsTile(
        settingKey: '${sensor.name}|${_values[0].name}|enabled',
        title: 'Enable $name',
        enabledLabel: 'Enabled',
        disabledLabel: 'Disabled',
        leading: Icon(sensor.icon),
        childrenIfEnabled: _getSingleValueWidgets(sensor, _values[0]),
        onChange: (value) {
          sensor.enable = value;
        },
    ));

    return children;
  }

}
