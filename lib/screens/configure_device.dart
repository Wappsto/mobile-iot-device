import 'package:flutter/material.dart';

class ConfigureDeviceScreen extends StatefulWidget {
  static const routeName = '/configuredevice';

  @override
  _ConfigureDeviceScreenState createState() => _ConfigureDeviceScreenState();
}

class _ConfigureDeviceScreenState extends State<ConfigureDeviceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Device'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("NOT IMPLEMENTED YET"),
          ],
        ),
      ),
    );
  }
}
