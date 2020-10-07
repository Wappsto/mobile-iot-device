import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:mobile_iot_device/utils/custom_route.dart';
import 'package:mobile_iot_device/dashboard.dart';
import 'package:mobile_iot_device/rest.dart';

final String fbClientId = "2562179333883383";
final String fbRedirectUrl = "https://wappsto-941e8.firebaseapp.com/__/auth/handler";

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

class LoginScreen extends StatelessWidget {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
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

  Future<void> firebaseLogin() async {

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> loginButtons = [
      SignInButton(
        Buttons.Google,
        onPressed: () async {
          signInWithGoogle().then((result) async {
              if (result != null) {
                var session = await firebaseSession(result);
                if(session != null) {
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString("session", session.id);

                  Navigator.of(context).pushReplacement(FadePageRoute(
                      builder: (context) => DashboardScreen(),
                  ));
                }
              }
          });
        },
      ),
      SignInButton(
        Buttons.Facebook,
        onPressed: () {
          signInWithFacebook(context).then((result) async {
              if (result != null) {
                var session = await firebaseSession(result);
                if(session != null) {
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString("session", session.id);

                  Navigator.of(context).pushReplacement(FadePageRoute(
                      builder: (context) => DashboardScreen(),
                  ));
                }
              }
          });
        },
      ),
    ];

    if (Platform.isIOS) {
      loginButtons.add(SignInButton(
          Buttons.Apple,
          onPressed: () {},
        )
      );
    }

    return SingleChildScrollView(
      child: Stack(
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
              return _loginUser(loginData);
            },
            onSignup: (loginData) {
              return _loginUser(loginData);
            },
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(FadePageRoute(
                  builder: (context) => DashboardScreen(),
              ));
            },
            onRecoverPassword: (name) {
              return _recoverPassword(name);
              // Show new password dialog
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: loginButtons,
            )
          )
        ]
      )
    );
  }

  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;


    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      final String token = await user.getIdToken();

      print('signInWithGoogle succeeded: $user');

      return token;
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("Google User Signed Out");
  }

  Future<String> signInWithFacebook(context) async {
    print("Sign In With Facebook");
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          selectedUrl:
          'https://www.facebook.com/dialog/oauth?client_id=$fbClientId&redirect_uri=$fbRedirectUrl&response_type=token&scope=email,public_profile,',
        ),
        maintainState: true),
    );
    print("Result:");
    print(result);
    if (result != null) {
      try {
        await Firebase.initializeApp();

        final facebookAuthCred = FacebookAuthProvider.credential(result);
        final authResult = await _auth.signInWithCredential(facebookAuthCred);

        final User user = authResult.user;

        if (user != null) {
          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);

          final User currentUser = _auth.currentUser;
          assert(user.uid == currentUser.uid);

          final String token = await user.getIdToken();

          print('signInWithFacebook succeeded: $user');

          return token;
        }
      } catch (e) {
        print(e);
      }
    }

    return null;
  }
}

class CustomWebView extends StatefulWidget {
  final String selectedUrl;

  CustomWebView({this.selectedUrl});

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
        if (url.contains("#access_token")) {
          succeed(url);
        }

        if (url.contains(
            "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
          denied();
        }
    });
  }

  denied() {
    Navigator.pop(context);
  }

  succeed(String url) {
    var params = url.split("access_token=");

    var endparam = params[1].split("&");

    Navigator.pop(context, endparam[0]);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.selectedUrl,
      appBar: new AppBar(
        backgroundColor: Color.fromRGBO(66, 103, 178, 1),
        title: new Text("Facebook login"),
    ));
  }
}
