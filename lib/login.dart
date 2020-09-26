import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:mobile_iot_device/utils/custom_route.dart';
import 'package:mobile_iot_device/dashboard.dart';
import 'package:mobile_iot_device/rest.dart';

class LoginScreen extends StatelessWidget {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const routeName = '/auth';
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _loginUser(LoginData data) async {
    try {
      var session = await fetchSession(data.name, data.password);
      final SharedPreferences prefs = await _prefs;
      prefs.setString("session", session.id);

      return null;
    } catch (e) {
      print(e);
      return "Wrong username/Password";
    }
  }

  Future<String> _recoverPassword(String name) async {
    return 'Not Implement yet';
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FlutterLogin(
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
            return _loginUser(loginData);
          },
          onSignup: (loginData) {
            print('Signup info');
            print('Name: ${loginData.name}');
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
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SignInButton(
                Buttons.Google,
                onPressed: () {},
              ),
              SignInButton(
                Buttons.Facebook,
                onPressed: () {},
              ),
              SignInButton(
                Buttons.Apple,
                onPressed: () {},
              )
            ],
          )
        )
      ]
    );
  }
}
