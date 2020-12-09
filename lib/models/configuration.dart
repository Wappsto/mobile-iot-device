import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';


abstract class Configuration extends Sensor {
  String current = "";

}
