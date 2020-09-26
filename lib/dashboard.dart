import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:mobile_iot_device/manager.dart';
import 'package:mobile_iot_device/login.dart';
import 'package:mobile_iot_device/models/sensor.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Manager _manager;
  List<Widget> _children;

  @override
  void initState() {
    super.initState();

    _manager = new Manager(state: this);
  }

  Future<void> setup(BuildContext context) async {
    if(_manager.connected) {
      return;
    }

    if(await _manager.setup()) {
      _buildList();
    } else {
      _goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    setup(context);

    return MaterialApp(
      title: 'Wappsto IoT Device',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Wappsto IoT Device')
        ),
        body: Center(
          child: _buildList()
        ),
      ),
    );
  }

  Future<bool> _goToLogin(BuildContext context) {
    return Navigator.of(context)
    .pushReplacementNamed(LoginScreen.routeName)
    // we dont want to pop the screen, just replace it completely
    .then((_) => false);
  }

  Widget _buildList() {
    var children = new List<Widget>();

    _manager.sensors.forEach((sen) => children.add(_tile(sen)));

    setState(() => _children = children);

    return ListView(
      children: _children
    );
  }

  ListTile _tile(Sensor sen) => ListTile(
    leading: Icon(
      sen.icon,
      color: Colors.blue[500],
    ),
    title: Text(
      sen.toString(),
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
      )
    ),
    subtitle: Text(
      sen.name
    ),
    trailing: Icon(Icons.keyboard_arrow_right),

    selected: sen.enabled,

    onTap: () {
      print("tap");
      setState(() {
          sen.toggleEnabled();
      });
    },
  );

  CheckboxListTile _tileCheck(Sensor sen) => CheckboxListTile(
    title: Text(
      sen.toString(),
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
      )
    ),
    subtitle: Text(
      sen.name
    ),
    secondary: Icon(
      sen.icon,
      color: Colors.blue[500],
    ),
    value: sen.enabled,
    onChanged: (bool value) {
      setState(() {
          sen.enabled = value;
      });
    },
  );
}
