import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class LocationSensor extends Sensor {
  Value _longValue;
  Value _latValue;
  double _lastLong = 0;
  double _lastLat = 0;

  LocationSensor() {
    icon = Icons.my_location;
    name = "Location";
  }

  void onData(Position position) {
    if(position == null) {
      return;
    }
    double dir = distanceBetween(_lastLat, _lastLong, position.latitude, position.longitude);

    if(dir > 10) {
      _lastLat = position.latitude;
      _lastLong = position.longitude;

      if(_longValue != null) {
        _longValue.update(position.longitude.toString());
      }
      if(_latValue != null) {
        _latValue.update(position.latitude.toString());
      }
    }

    text = "${position.latitude}, ${position.longitude}";
    call();
  }

  void start() {
    print("Starting location");

    requestPermission().then((LocationPermission permission) {
        print("Permission $permission");
        if(permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
          text = "No Location Data";
        } else {
          subscription = getPositionStream(desiredAccuracy: LocationAccuracy.high).listen(onData);
        };
    });
  }

  void linkValue(Device device) {
    _latValue = device.findValue(name: 'Latitude');
    if(_latValue == null) {
      _latValue = device.createNumberValue('Latitude', 'latitude', -90, 90, 0.000001, '°N');
      _latValue.createState(StateType.Report, data: "0");
    }
    _longValue = device.findValue(name: 'Longitude');
    if(_longValue == null) {
      _longValue = device.createNumberValue('Longitude', 'longitude', -180, 180, 0.000001, '°E');
      _longValue.createState(StateType.Report, data: "0");
    }
  }
}
