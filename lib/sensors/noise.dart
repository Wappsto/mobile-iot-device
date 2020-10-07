import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:mobile_iot_device/models/sensor.dart';
import 'package:mobile_iot_device/models/device.dart';
import 'package:mobile_iot_device/models/value.dart';
import 'package:mobile_iot_device/models/state.dart';

class NoiseSensor extends Sensor {
  NoiseMeter _noiseMeter = new NoiseMeter();

  String _noiseMax = "";
  String _noiseMean = "";

  Value _value;
  Value _rawValue;

  NoiseSensor() {
    icon = Icons.mic;
    name = "Noise Sensor";
  }

  String dbToText(double db) {
    if(db >= 130) {
      return "PAINFUL & DANGEROUS";
    } else if(db >= 120) {
      return "UNCOMFORTABLE";
    } else if(db >= 90) {
      return "VERY LOUD";
    } else if(db >= 70) {
      return "LOUD";
    } else if(db >= 50) {
      return "MODERATE";
    } else {
      return "SOFT";
    }
  }

  void onData(NoiseReading noiseReading) {
    String mean = dbToText(noiseReading.meanDecibel);
    String max = dbToText(noiseReading.maxDecibel);
    if(mean != _noiseMean || max != _noiseMax) {
      _noiseMean = mean;
      _noiseMax = max;

      if(noiseReading.meanDecibel.isFinite) {
        if(_rawValue != null) {
          if(_rawValue.update(noiseReading.meanDecibel.toInt().toString())) {
            if(_value != null) {
              _value.update(mean);
            }
          }
        }

        text = "$mean (${noiseReading.meanDecibel.toInt().toString()} db)";
        call();
      } else {
        print("Invalid value from MIC");
      }
    }
  }

  void start() async {
    try {
      subscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void linkValue(Device device) {
    _value = device.findValue(name: 'Noise');
    if(_value == null) {
      _value = device.createStringValue('Noise', 'noise_meaning', 30);
      _value.createState(StateType.Report, data: "SOFT");
    }
    _rawValue = device.findValue(name: 'Sound');
    if(_rawValue == null) {
      _rawValue = device.createNumberValue('Sound', 'sound_level', 0, 200, 1, 'db');
      _rawValue.createState(StateType.Report, data: "0");
    }

    _rawValue.setDelta(20);
  }
}
