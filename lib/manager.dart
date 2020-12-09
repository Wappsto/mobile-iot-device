import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

import 'package:slx_snitch/rest.dart';
import 'package:slx_snitch/wappsto.dart';
import 'package:slx_snitch/utils/phone_info.dart';
import 'package:slx_snitch/models/session.dart';
import 'package:slx_snitch/models/sensor.dart';
import 'package:slx_snitch/models/configuration.dart';
import 'package:slx_snitch/models/network.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/creator.dart';
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


class Manager {
  String _host = "collector.wappsto.com";
  int _port = 443;
  SharedPreferences _prefs;
  List<Sensor> _sensors = List<Sensor>();
  List<Configuration> _configs = List<Configuration>();
  String networkID;
  Wappsto wappsto;
  Network network;
  var state;
  bool _connected = false;
  String _ca;
  String _cert;
  String _key;
  String error;

  Manager({this.state, this.networkID});

  Future<bool> setup() async {
    _connected = false;
    _prefs = await SharedPreferences.getInstance();

    _sensors.add(NoiseSensor());
    _sensors.add(LightSensor());
    _sensors.add(LocationSensor());
    _sensors.add(WifiSensor());
    _sensors.add(AccelerometerSensor());
    _sensors.add(GyroscopeSensor());
    //_sensors.add(new MagnetometerSensor());
    _sensors.add(CompassSensor());
    _sensors.add(BatterySensor());

    _configs.add(PhoneID());
    _configs.add(RunTime());

    var p;
    if(networkID == null) {
      p = _prefs;
    }
    _sensors.forEach((s) => s.setup(update, p));
    _configs.forEach((c) => c.setup(update, p));

    final String session = _prefs.getString("session");

    if(networkID == null) {
      List<String> certs = await loadCerts();
      if(certs == null) {
        return false;
      }
      _ca = certs[0];
      _cert = certs[1];
      _key = certs[2];
    } else {
      print("Loading certs for $networkID");

      try {
        network = await RestAPI.fetchNetwork(session, networkID);
      } catch(e) {
        print(e);
        error = e.result;
        return false;
      }
      Session sen = Session(id: session);
      List<Creator> creators = await RestAPI.fetchCreator(sen);
      Creator creator = creators.firstWhere((creator) => creator.network == networkID);

      if(creator == null) {
        return false;
      }

      _ca = creator.ca;
      _cert = creator.certificate;
      _key = creator.privateKey;
    }

    wappsto = new Wappsto(host: _host, port: _port, ca: _ca, cert: _cert, key: _key);

    if(networkID != null) {
      network = await RestAPI.fetchFullNetwork(session, networkID, wappsto);
      linkValues(network.devices[0], false);
    }

    return true;
  }

  bool get connected {
    return _connected;
  }

  List<Sensor> get sensors {
    return _sensors;
  }

  List<Configuration> get configurations {
    return _configs;
  }

  Future<bool> start() async {
    if(!await connect()) {
      return false;
    }

    if(!await createNetwork()) {
      wappsto.stop();
      return false;
    }

    _connected = true;
    _sensors.forEach((s) => s.run());
    _configs.forEach((c) => c.run());

    return true;
  }

  Future<void> stop() async {
    print("Stopping");
    _connected = false;
    _sensors.forEach((s) => s.stop());
    if(wappsto != null) {
      await wappsto.stop();
    }
  }

  void update() {
    if(_connected && state.mounted) {
      state.setState(() { });
    }
  }

  Future<bool> connect() async {
    try {
      await wappsto.connect();

      print("Connected to Wappsto on $_host:$_port");

      return true;
    } catch(e, backtrace) {
      print("ERR");
      print(e);
      print(backtrace);
    }

    return false;
  }

  Future<bool> createNetwork() async {
    final String session = _prefs.getString("session");

    if(networkID == null) {
      network = await generateNetwork();

      try {
        await wappsto.postNetwork(network);
        await RestAPI.claimNetwork(session, network.id);
      } catch(e, backtrace) {
        print("ERR");
        print(e);
        print(backtrace);

        if(network != null) {
          print(network.toJsonString());
        }
      }
    }

    return true;
  }

  void linkValues(Device device, bool create) {
    _sensors.forEach((s) => s.linkValue(device, create));
    _configs.forEach((c) => c.linkValue(device, create));
  }

  Future<List<String> > loadCerts() async {
    var ca = _prefs.getString('ca') ?? "";

    if(ca == "") {
      print("Loading creators from Wappsto.");
      final String strSession = _prefs.getString("session");
      final Session session = await RestAPI.validateSession(strSession);
      if(session == null) {
        _prefs.remove("session");
        return null;
      }

      List<String> creatorIds = _prefs.getStringList("creator_ids");
      creatorIds ??= List<String>();
      final List<Creator> creators = await RestAPI.fetchCreator(session);
      Creator creator;
      for(var i=0; i<creators.length; i++) {
        if(creatorIds.contains(creators[i].id)) {
          creator = creators[i];
          break;
        }
      }

      if(creator == null) {
        print("Loading new certificates from Wappsto");
        creator = await RestAPI.createCreator(session, 'Mobile IoT Device');
        creatorIds.add(creator.id);
        _prefs.setStringList("creator_ids", creatorIds);
      }

      _prefs.setString("ca", creator.ca);
      _prefs.setString("certificate", creator.certificate);
      _prefs.setString("private_key", creator.privateKey);
    }

    return [_prefs.getString("ca"), _prefs.getString("certificate"), _prefs.getString("private_key")];
  }

  Future<Network> generateNetwork() async {
    String rn = _prefs.getString("network") ?? "";
    Network network;
    Device device;
    String networkName;
    String deviceName;
    if (Platform.isAndroid) {
      networkName = 'Android IoT Network';
      deviceName = 'Android IoT Device';
    } else {
      networkName = 'Apple IoT Network';
      deviceName = 'Apple IoT Device';
    }

    if(rn == "") {
      network = wappsto.createNetwork(networkName);
      device = network.createDevice(deviceName);
    } else {
      network = Network.fromJson(json.decode(rn), wappsto);
      device = network.findDevice(name: deviceName);
    }

    Map<String, dynamic> deviceData = await PhoneInfo.getPlatformState();

    if (Platform.isAndroid) {
      device.manufacturer = deviceData['manufacturer'];
      device.product = deviceData['model'];
      device.version = deviceData['version.release'];
      device.serial = deviceData['androidId'];
    } else {
      device.manufacturer = 'APPLE';
      device.product = deviceData['model'];
      device.version = deviceData['systemVersion'];
      device.serial = deviceData['identifierForVendor'];
    }
    device.communication = 'WiFi';
    device.protocol = 'JsonRPC';

    linkValues(device, true);

    _prefs.setString("network", network.toJsonString());

    return network;
  }

}
