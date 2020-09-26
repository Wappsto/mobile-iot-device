import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:mobile_iot_device/splash.dart';
import 'package:mobile_iot_device/utils/custom_route.dart';
import 'package:mobile_iot_device/login.dart';
import 'package:mobile_iot_device/dashboard.dart';
import 'package:mobile_iot_device/utils/transition_route_observer.dart';


void main() {
  runApp(
    SplashApp(
      key: UniqueKey(),
      onInitializationComplete: (SharedPreferences prefs) => runMainApp(prefs),
    ),
  );
}

void runMainApp(SharedPreferences prefs) {
  runApp(
    MyApp(prefs),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp(this.prefs);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wappsto IoT Device',
      home: getStartScreen(),
      navigatorObservers: [TransitionRouteObserver()],
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
  }

  Widget getStartScreen() {
    var session = prefs.getString("session");

    if(session == null) {
      return  LoginScreen();
    } else {
      return DashboardScreen();
    }
  }
}
