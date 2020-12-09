import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:slx_snitch/rest.dart';
import 'package:slx_snitch/models/network.dart';
import 'package:slx_snitch/screens/run_sample.dart';

class ListDevicesScreen extends StatefulWidget {
  static const routeName = '/listdevices';

  @override
  _ListDevicesScreenState createState() => _ListDevicesScreenState();
}

class _ListDevicesScreenState extends State<ListDevicesScreen> {
  List<Network> _networks = List<Network>();
  List<Widget> _children;

  @override
  void initState() {
    super.initState();

    setup();
  }

  Future<void> setup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String session = prefs.getString("session");
    List<Network> tmp = await RestAPI.fetchNetworks(session);
    setState(() => {
        _networks = tmp
    });

    _buildList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device'),
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
    var children = List<Widget>();

    _networks.forEach((n) => children.add(_tile(n)));

    setState(() => _children = children);

    return ListView(
      children: _children
    );
  }

  ListTile _tile(Network network) => ListTile(
    title: Text(
      network.name,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
      )
    ),
    subtitle: Text(
      network.id
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RunScreen(networkID: network.id)),
      );
    },
  );

}
