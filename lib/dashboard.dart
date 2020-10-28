import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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

    _manager = Manager(state: this);
    setup(context);
  }

  @override
  void dispose() {
    _manager.stop();
    super.dispose();
  }

  Future<void> setup(BuildContext context) async {
    if(await _manager.setup()) {
      _buildList();
    } else {
      _goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SLX Mobile IoT Device'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _buildList()
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList("creator_ids");
    prefs.clear();
    prefs.setStringList("creator_ids", ids);

    _manager.stop();

    LoginScreen.logout();

    _goToLogin(context);
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
    selectedTileColor: Colors.blue[100],
    onTap: () {
      setState(() {
          sen.toggleEnabled();
      });
    },
  );
}
