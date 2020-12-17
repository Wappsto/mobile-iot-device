import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'dart:async';
import 'package:slx_snitch/manager.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/value.dart';

class WappstoCacheProvider extends CacheProvider {
  static final WappstoCacheProvider _instance = WappstoCacheProvider._internal();
  Manager manager;

  factory WappstoCacheProvider() {
    return _instance;
  }

  WappstoCacheProvider._internal() {
  }

  Future<void> init() async {}

  bool containsKey(String key) {
    List<dynamic> keys = _parseKey(key);
    return (keys[0] != null);
  }

  bool getBool(String key) {
    print("getBool: $key");
    return true;
  }

  void setBool(String key, bool value) {
    print("setBool: $key");
  }

  double getDouble(String key) {
    print("getDouble: $key");
    return 0.0;
  }

  void setDouble(String key, double value) {
    print("setDouble: $key");
  }

  int getInt(String key) {
    print("getInt: $key");
    return 0;
  }

  void setInt(String key, int value) {
    print("setInt: $key");
  }

  String getString(String key) {
    print("getString: $key");
    return "";
  }

  void setString(String key, String value) {
    print("setString: $key");
  }

  void remove(String key) {
    print("remove: $key");
  }

  void removeAll() {
    print("removeAll");
  }

  List<dynamic> _parseKey(String key) {
    List<String> keys = key.split("|");
    List<dynamic> res = List<dynamic>();
    res.add(manager.findSensor(keys[0]));
    if(keys.length == 2 || res[0] == null) {
      res.add(null);
    } else {
      res.add(res[0].getValue(keys[1]));
    }
    res.add(keys.last);
    return res;
  }

  T getValue<T>(String key, T defaultValue) {
    List<dynamic> keys = _parseKey(key);
    Sensor sen = keys[0];
    Value val = keys[1];
    String vKey = keys[2];

    print("getvalue: $key");
    print(T);
    switch(vKey) {
      case "enabled":
      return sen.enabled as T;
      case "delta":
      if(val.delta == null) {
        return 0.0 as T;
      }
      return val.delta as T;
      case "period":
      if(val.period == null) {
        return 0.0 as T;
      }
      return val.period as T;
    }

    print("not handled $vKey");
  }

  void setObject<T>(String key, T value) {
    print("setObject: $key => $value");
    List<dynamic> keys = _parseKey(key);
    Sensor sen = keys[0];
    Value val = keys[1];
    String vKey = keys[2];

    switch(vKey) {
      case "enabled":
      sen.enable = value as bool;
      break;
      case "delta":
      val.delta = value as double;
      break;
      case "period":
      val.period = value as double;
      break;
    }

    manager.saveNetwork();
  }

  Set<E> getKeys<E>() {
    print("getKeys:");
  }
}
