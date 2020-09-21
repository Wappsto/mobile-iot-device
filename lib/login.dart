import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_route.dart';
import 'dashboard.dart';
import 'rest.dart';

class LoginScreen extends StatelessWidget {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const routeName = '/auth';

  Future<String> _loginUser(LoginData data) async {
    try {
      var session = await fetchSession(data.name, data.password);
      final SharedPreferences prefs = await _prefs;
      prefs.setString("session", session.id);

      return null;
    } catch (e) {
      return "Wrong username/Password";
    }
  }

  Future<String> _recoverPassword(String name) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return FlutterLogin(
      title: "IoT Device",
      logo: 'assets/images/logo.png',
      logoTag: "Seluxit Logo",
      titleTag: "IoT Device Title",
      emailValidator: (value) {
        if (!value.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
            builder: (context) => DashboardScreen(),
        ));
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
    );
  }
}
