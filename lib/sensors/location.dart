import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class LocationSensor extends Sensor {
  double _lastLong = 0;
  double _lastLat = 0;

  LocationSensor() {
    icon = Icons.my_location;
    name = "Location";
    valueName.add('Latitude');
    valueName.add('Longitude');
  }

  void onData(Position position) {
    if(position == null) {
      return;
    }
    double dir = distanceBetween(_lastLat, _lastLong, position.latitude, position.longitude);

    if(dir > 10) {
      _lastLat = position.latitude;
      _lastLong = position.longitude;

      if(value[0] != null) {
        value[0].update(position.latitude.toString());
      }
      if(value[1] != null) {
        value[1].update(position.longitude.toString());
      }
    }

    text = "${position.latitude}, ${position.longitude}";
    call();
  }

  void start() {
    requestPermission().then((LocationPermission permission) {
        if(permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
          text = "No Location Data";
        } else {
          subscription = getPositionStream(desiredAccuracy: LocationAccuracy.high).listen(onData);
          //Geolocator.getCurrentPosition().then(onData);
        }
    });
  }

  Value createValue(Device device, String name) {
    Value value;
    if(name == 'Latitude') {
      value = device.createNumberValue('Latitude', 'latitude', -90, 90, 0.000001, '°N');
      value.createState(StateType.Report, data: "0");
    } else {
      value = device.createNumberValue('Longitude', 'longitude', -180, 180, 0.000001, '°E');
      value.createState(StateType.Report, data: "0");
    }
    return value;
  }
}
