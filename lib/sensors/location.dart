import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class LocationSensor extends Sensor {
  Value _longValue;
  Value _latValue;
  var _geolocator;
  String _locText = "";

  LocationSensor() {
    icon = Icons.my_location;
    name = "Location";
  }

  void start() {
    print("Starting location");
    _geolocator = Geolocator();

    _geolocator.checkGeolocationPermissionStatus().then((GeolocationStatus status) {
        print("Status ${status}");
        if(status == GeolocationStatus.denied ||
          status == GeolocationStatus.disabled) {
          text = "No Location Data";
        }
    });

    _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
        print("Got position");

        if(_longValue != null) {
          _longValue.update(position.longitude.toString());
        }
        if(_latValue != null) {
          _latValue.update(position.latitude.toString());
        }
        text = "${position.latitude}, ${position.longitude}";
        call();
    });
  }

  void linkValue(Device device) {
    _latValue = device.findValue(name: 'Latitude');
    if(_latValue == null) {
      _latValue = device.createNumberValue('Latitude', 'latitude', -90, 90, 0.000001, '°');
      _latValue.createState(StateType.Report, data: "0");
    } else {
      _latValue.setType('latitude');
    }
    _longValue = device.findValue(name: 'Longitude');
    if(_longValue == null) {
      _longValue = device.createNumberValue('Longitude', 'longitude', -180, 180, 0.000001, '°');
      _longValue.createState(StateType.Report, data: "0");
    } else {
      _longValue.setType('longitude');
    }
  }
}
