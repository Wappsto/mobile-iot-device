import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

import 'rest.dart';
import 'wappsto.dart';
import 'models/session.dart';
import 'models/creator.dart';
import 'models/sensor.dart';
import 'models/network.dart';
import 'models/device.dart';
import 'lux.dart';
import 'noise.dart';
import 'location.dart';
import 'wifi.dart';
import 'accelerometer.dart';
import 'gyroscope.dart';
import 'activity.dart';

class Manager {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Sensor> _sensors = new List<Sensor>();
  Wappsto wappsto;
  Network network;
  var state;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData;

  Manager({this.state});

  void setup() async {
    _sensors.add(new NoiseSensor());
    _sensors.add(new LightSensor());
    _sensors.add(new LocationSensor());
    _sensors.add(new WifiSensor());
    _sensors.add(new AccelerometerSensor());
    _sensors.add(new GyroscopeSensor());
    _sensors.add(new ActivitySensor());

    _sensors.forEach((s) => s.setCallback(update));

    initPlatformState();

    await connect();

    start();
  }

  List<Sensor> get sensors {
    return _sensors;
  }

  void start() async {
    print("Starting");
    _sensors.forEach((s) => s.start());
  }

  void stop() async {
    _sensors.forEach((s) => s.stop());
  }

  void update() {
    state.setState(() {
    });
  }

  void connect() async {
    List<String> certs = await loadCerts();
    String ca = certs[0];
    String cert = certs[1];
    String key = certs[2];

    String host = "collector.wappsto.com";
    int port = 443;

    wappsto = new Wappsto(host: host, port: port, ca: ca, cert: cert, key: key);

    try {
      await wappsto.connect();

      print("Connected");

      network = await createNetwork();

      var res = await wappsto.postNetwork(network);
      print(res);

      start();
    } catch(e, backtrace) {
      print("ERR");
      print(e);
      print(backtrace);

      if(network != null) {
        print(network.toJsonString());
      }

      //print(e.data);
    }

    print("Done connect");
  }

  Future<List<String> > loadCerts() async {
    final SharedPreferences prefs = await _prefs;
    var ca = prefs.getString('ca') ?? "";

    if(ca == "") {
      final str_session = prefs.getString("session");
      final session = new Session(id: str_session);
      final creators = await fetchCreator(session);

      Creator c = creators[0];

      prefs.setString("ca", c.ca);
      prefs.setString("certificate", c.certificate);
      prefs.setString("private_key", c.private_key);
    } else {
      print("Loading from prefs");
    }

    return [prefs.getString("ca"), prefs.getString("certificate"), prefs.getString("private_key")];
  }

  Future<Network> createNetwork() async {
    final SharedPreferences prefs = await _prefs;

    String rn = prefs.getString("network") ?? "";
    Network network;
    Device device;

    if(rn == "") {
      network = wappsto.createNetwork('Android IoT Network');
      device = network.createDevice('Android IoT Device');
    } else {
      network = Network.fromJson(json.decode(rn), wappsto);
      device = network.findDevice(name: 'Android IoT Device');
    }

    if (Platform.isAndroid) {
      device.manufacturer = deviceData['manufacturer'];
      device.product = deviceData['model'];
      device.version = deviceData['version.incremental'];
    } else {
      device.manufacturer = 'APPLE';
      device.product = deviceData['model'];
      device.version = deviceData['systemVersion'];
    }
    device.communication = 'WiFi';
    device.protocol = 'JsonRPC';

    _sensors.forEach((s) => s.linkValue(device));

    prefs.setString("network", network.toJsonString());

    return network;
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
