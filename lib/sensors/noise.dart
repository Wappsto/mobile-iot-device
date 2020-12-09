import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class NoiseSensor extends Sensor {
  NoiseMeter _noiseMeter = new NoiseMeter();

  String _noiseMax = "";
  String _noiseMean = "";

  NoiseSensor() {
    icon = Icons.mic;
    name = "Noise Sensor";
    valueName.add('Noise');
    valueName.add('Sound');
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
        if(value[1] != null) {
          if(value[1].update(noiseReading.meanDecibel.toInt().toString())) {
            if(value[0] != null) {
              value[0].update(mean);
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

  Value createValue(Device device, String name) {
    Value value;
    if(name == 'Noise') {
      value = device.createStringValue(name, 'noise_meaning', 30);
      value.createState(StateType.Report, data: "SOFT");
    } else {
      value = device.createNumberValue(name, 'sound_level', 0, 200, 1, 'db');
      value.createState(StateType.Report, data: "0");
      value.setDelta(20);
    }
    return value;
  }
}
