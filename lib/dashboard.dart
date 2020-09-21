import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'manager.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Manager _manager;

  @override
  void initState() {
    super.initState();

    _manager = new Manager(state: this);

    _manager.setup();
  }

  @override
  Widget build(BuildContext context) {
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
    .pushReplacementNamed('/')
    // we dont want to pop the screen, just replace it completely
    .then((_) => false);
  }

  Widget _buildList() {
    var children = new List<Widget>();

    _manager.sensors.forEach((sen) => children.add(_tile(sen.toString(), sen.name, sen.icon)));

    return ListView(
      children: children
    );
  }

  ListTile _tile(String title, String subtitle, IconData icon) => ListTile(
    title: Text(title,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
    )),
    subtitle: Text(subtitle),
    leading: Icon(
      icon,
      color: Colors.blue[500],
    ),
  );
}
