import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_iot_device/splash.dart';
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
    MobileIotDevice(prefs),
  );
}

class MobileIotDevice extends StatelessWidget {
  final SharedPreferences prefs;
  MobileIotDevice(this.prefs);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLX Mobile IoT Device',
      home: getStartScreen(),
      navigatorObservers: [TransitionRouteObserver()],
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
      theme: ThemeData(
        primaryColor: Color(0xFF1F324D),
        accentColor: Colors.blue[400],
        errorColor: Colors.red[400],
      )
    );
  }

  Widget getStartScreen() {
    var session = prefs.getString("session");

    if(session == null) {
      return LoginScreen();
    } else {
      return DashboardScreen();
    }
  }
}
