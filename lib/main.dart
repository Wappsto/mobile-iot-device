import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter/services.dart';

import 'package:slx_snitch/splash.dart';
import 'package:slx_snitch/screens/login.dart';
import 'package:slx_snitch/screens/dashboard.dart';
import 'package:slx_snitch/utils/transition_route_observer.dart';
import 'package:slx_snitch/utils/cache_provider.dart';

void main() async {
  Settings.init(cacheProvider: WappstoCacheProvider());

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // To turn off landscape mode

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
