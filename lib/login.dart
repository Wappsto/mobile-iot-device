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

  @override
  Widget build(BuildContext context) {
    List<Widget> loginButtons = [
      SignInButton(
        Buttons.Google,
        onPressed: () async {
          signInWithGoogle(context);
        },
      ),
      SignInButton(
        Buttons.Facebook,
        onPressed: () {
          signInWithFacebook(context);
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
      );
  }

  Future<void> firebaseLogin(AuthCredential creds, BuildContext context) async {
    final authResult = await _auth.signInWithCredential(creds);
    final User user = authResult.user;

    if (user == null) {
      return;
    }

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    final String token = await user.getIdToken();

    if (token == null) {
        return;
    }

    var session = await firebaseSession(token);
    if(session == null) {
      return;
    }

    final SharedPreferences prefs = await _prefs;
    prefs.setString("session", session.id);

    Navigator.of(context).pushReplacement(FadePageRoute(
        builder: (context) => DashboardScreen(),
    ));
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential creds = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    firebaseLogin(creds, context);
  }

  Future<void> signOutGoogle() async {
    try {
      await googleSignIn.signOut();
    } catch(e) {
      print(e);
    }

    print("Google User Signed Out");
  }

  Future<void> signInWithFacebook(BuildContext context) async {
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

    if (result != null) {
      try {
        await Firebase.initializeApp();
        final AuthCredential creds = FacebookAuthProvider.credential(result);
        firebaseLogin(creds, context);
      } catch (e) {
        print(e);
      }
    }
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
