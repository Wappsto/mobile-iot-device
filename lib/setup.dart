import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/configuration.dart';

import 'package:slx_snitch/sensors/light.dart';
import 'package:slx_snitch/sensors/noise.dart';
import 'package:slx_snitch/sensors/location.dart';
import 'package:slx_snitch/sensors/wifi.dart';
import 'package:slx_snitch/sensors/accelerometer.dart';
import 'package:slx_snitch/sensors/gyroscope.dart';
//import 'package:slx_snitch/sensors/magnetometer.dart';
import 'package:slx_snitch/sensors/compass.dart';
import 'package:slx_snitch/sensors/battery.dart';
import 'package:slx_snitch/sensors/phone_id.dart';
import 'package:slx_snitch/sensors/run_time.dart';
import 'package:slx_snitch/sensors/picture.dart';

List<Sensor> getSensors() {
  List<Sensor> sensors = List<Sensor>();

  sensors.add(NoiseSensor());
  sensors.add(LightSensor());
  sensors.add(LocationSensor());
  sensors.add(WifiSensor());
  sensors.add(AccelerometerSensor());
  sensors.add(GyroscopeSensor());
  //sensors.add(new MagnetometerSensor());
  sensors.add(CompassSensor());
  sensors.add(BatterySensor());

  return sensors;
}

List<Configuration> getConfigs() {
  List<Configuration> configs = List<Configuration>();

  configs.add(PhoneID());
  configs.add(RunTime());
  configs.add(Picture());

  return configs;
}
