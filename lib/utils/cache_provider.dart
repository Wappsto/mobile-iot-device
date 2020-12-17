import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'dart:async';

class WappstoCacheProvider extends CacheProvider {

  Future<void> init() async {}

  bool containsKey(String key) {
    return false;
  }

  bool getBool(String key) {
    return false;
  }

  void setBool(String key, bool value){
  }

  double getDouble(String key) {
    return 0.0;
  }

  void setDouble(String key, double value) {
  }

  int getInt(String key) {
    return 0;
  }

  void setInt(String key, int value) {
  }

  String getString(String key) {
    return "";
  }

  void setString(String key, String value) {
  }

  void remove(String key) {
  }

  void removeAll() {
  }

  T getValue<T>(String key, T defaultValue) {
    return null;
  }

  void setObject<T>(String key, T value) {
  }

  Set<E> getKeys<E>() {
    return null;
  }
}
