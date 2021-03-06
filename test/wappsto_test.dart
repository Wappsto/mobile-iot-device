import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:slx_snitch/wappsto.dart';
import 'package:slx_snitch/rest.dart';
import 'package:slx_snitch/models/network.dart';


void main() async {
  return;

  var loadFromServer = !await File('ca.pem').exists();

  if(loadFromServer) {
    final session = await RestAPI.fetchSession('', '');
    final creators = await RestAPI.fetchCreator(session);

    creators.forEach(print);

    var c = creators[0];

    print(c.ca);
    print(c.certificate);
    print(c.privateKey);
    File('ca.pem').writeAsStringSync(c.ca);
    File('cert.pem').writeAsStringSync(c.certificate);
    File('key.pem').writeAsStringSync(c.privateKey);
  }

  String ca = await File('ca.pem').readAsString();
  String cert = await File('cert.pem').readAsString();
  String key = await File('key.pem').readAsString();
  String host = "collector.wappsto.com";
  int port = 443;

  Wappsto w = new Wappsto(host: host, port: port, ca: ca, cert: cert, key: key);

  await w.connect();

  w.rawSend(['PUT', '/network/c4023bbd-7a34-44a5-bd75-5e32db712e05/device/6b8fc3f2-f293-4d0e-b6cf-ab4f2e9030e7/value/bf2885ab-6ca0-4bd2-9444-da2271d54c52/state/9ab5bb53-ba54-4e74-8c54-523e0b4f5937', '{"meta": {"id": "9ab5bb53-ba54-4e74-8c54-523e0b4f5937", "version": "2.0", "type": "state"}, "type": "Report", "timestamp": "2020-08-21T18:48:05.777152Z", "data": "SOFT"}']);

  const oneSec = const Duration(seconds:3);
  new Timer.periodic(oneSec, (Timer t) {
      w.rawSend(['PUT', '/network/c4023bbd-7a34-44a5-bd75-5e32db712e05/device/6b8fc3f2-f293-4d0e-b6cf-ab4f2e9030e7/value/bf2885ab-6ca0-4bd2-9444-da2271d54c52/state/9ab5bb53-ba54-4e74-8c54-523e0b4f5937', '{"meta": {"id": "9ab5bb53-ba54-4e74-8c54-523e0b4f5937", "version": "2.0", "type": "state"}, "type": "Report", "timestamp": "2020-08-21T18:48:05.777152Z", "data": "SOFT"}']);
      w.rawSend(['PUT', '/network/c4023bbd-7a34-44a5-bd75-5e32db712e05/device/6b8fc3f2-f293-4d0e-b6cf-ab4f2e9030e7/value/bf2885ab-6ca0-4bd2-9444-da2271d54c52/state/9ab5bb53-ba54-4e74-8c54-523e0b4f5937', '{"meta": {"id": "9ab5bb53-ba54-4e74-8c54-523e0b4f5937", "version": "2.0", "type": "state"}, "type": "Report", "timestamp": "2020-08-21T18:48:05.777152Z", "data": "SOFT"}']);

  });

  return;
  var network;
  var device;
  var value;
  var state;

  network = w.createNetwork('Android IoT Network');
  print(network);

  device = network.createDevice('Android IoT Device');
  print(device);

  value = device.createNumberValue('Temperature', -20, 50, 1, 'celcius');
  print(value);

  state = value.createState('Report');
  state.update("10");
  print(state);

  print(network.toJson());

  await File("network.json").writeAsString(network.toJsonString());

  String tmp = await File("network.json").readAsString();

  network = Network.fromJson(json.decode(tmp), w);
  print(network.toJson());

  device = network.findDevice(name: 'Android IoT Device');
  print(device);

  value = device.findValue(name: 'Temperature');
  print(value);

  state = value.states[0];
  print(state);

  state.update('11');

  try {
    await w.connect();

    await w.postNetwork(network);

  } catch(e) {
    print("ERR");
    print(e);
    print(e.data);
  }

  //const oneSec = const Duration(seconds:1);
  //int count = 1;
  //new Timer.periodic(oneSec, (Timer t) => {count++, state.update(count.toString()), w.updateState(state) });
  //var res = await client.sendRequest('GET', {'url': '/network'});
  //print(res);

}
