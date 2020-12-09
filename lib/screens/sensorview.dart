import 'package:flutter/material.dart';
import 'dart:async';

import 'package:slx_snitch/manager.dart';
import 'package:slx_snitch/models/sensor.dart';

class SensorScreen extends StatefulWidget {
  static const routeName = '/sensor';

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  Manager _manager;
  List<Widget> _children;

  @override
  void initState() {
    super.initState();

    _manager = Manager(state: this);
    setup();
  }

  @override
  void dispose() {
    _manager.stop();
    super.dispose();
  }

  Future<void> setup() async {
    if(await _manager.setup()) {
      _buildList();
      await _manager.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SLX Pocket'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Center(
        child: _buildList()
      ),
    );
  }

  Widget _buildList() {
    var children = new List<Widget>();

    _manager.sensors.forEach((sen) => children.add(_tile(sen)));

    if(mounted) {
      setState(() => _children = children);
    }

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
