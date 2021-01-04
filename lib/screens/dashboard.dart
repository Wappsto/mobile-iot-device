import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:slx_snitch/rest.dart';
import 'package:slx_snitch/manager.dart';
import 'package:slx_snitch/models/session.dart';
import 'package:slx_snitch/screens/login.dart';
import 'package:slx_snitch/screens/sensorview.dart';
import 'package:slx_snitch/screens/list_devices.dart';
import 'package:slx_snitch/screens/configure_device.dart';
import 'package:slx_snitch/screens/run_sample.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Manager _manager;

  @override
  void initState() {
    super.initState();

    setup(context);
  }

  @override
  void dispose() {
    if(_manager != null) {
      _manager.stop();
    }
    super.dispose();
  }

  Future<void> setup(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    final String strSession = prefs.getString("session");
    final Session session = await RestAPI.validateSession(strSession);
    if(session == null) {
      prefs.remove("session");
      _goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SLX Snitch App'),
        elevation: .1,
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
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        child: Row(
          children: [
            GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(3.0),
              children: <Widget>[
                makeDashboardItem("Scan QR code", Icons.qr_code_scanner, fun: _scan),
                makeDashboardItem("Select Device", Icons.format_list_bulleted, widget: ListDevicesScreen()),
                makeDashboardItem("New Device", Icons.add, widget: ConfigureDeviceScreen()),
                makeDashboardItem("Pocket IoT", Icons.phone_android, widget: SensorScreen()),
              ],
            ),
            new RaisedButton(
              onPressed: _openWappsto,
              child: new Text('View your data in wappsto.com'),
            ),
          ]
        ),
      ),
    );
  }

  _openWappsto() async {
    const url = 'https://wappsto.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _scan() async {
    var result = await BarcodeScanner.scan();
    if (result != null && result.rawContent != "") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RunScreen(networkID: result.rawContent)),
      );
    }
  }

  Card makeDashboardItem(String title, IconData icon, {Widget widget, Function fun}) {
    return Card(
      elevation: 1.0,
      margin: new EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1.0)),
        child: new InkWell(
          onTap: () {
            if(widget != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget),
              );
            } else {
              fun();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              SizedBox(height: 50.0),
              Center(
                child: Icon(
                  icon,
                  size: 40.0,
                  color: Colors.black,
              )),
              SizedBox(height: 20.0),
              new Center(
                child: new Text(title,
                  style:
                  new TextStyle(fontSize: 18.0, color: Colors.black)),
              )
            ],
          ),
        ),
    ));
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList("creator_ids");
    prefs.clear();
    prefs.setStringList("creator_ids", ids);

    if(_manager != null) {
      _manager.stop();
    }

    LoginScreen.logout();

    _goToLogin(context);
  }

  Future<bool> _goToLogin(BuildContext context) {
    return Navigator.of(context)
    .pushReplacementNamed(LoginScreen.routeName)
    // we dont want to pop the screen, just replace it completely
    .then((_) => false);
  }

}
