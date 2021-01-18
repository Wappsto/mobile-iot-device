import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slx_snitch/screens/dashboard.dart';
import 'package:slx_snitch/host.dart';
import 'package:slx_snitch/rest.dart';
import 'package:slx_snitch/utils/facebook_login_view.dart';

class LoginData extends ControllerMVC {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final String fbClientId = "2562179333883383";
  final String fbRedirectUrl = "https://wappsto-941e8.firebaseapp.com/__/auth/handler";

  bool _signUpActive = false;
  bool _signInActive = true;
  bool _resetActive = false;

  /// Singleton Factory
  factory LoginData() {
    if (_this == null) _this = LoginData._();
    return _this;
  }

  static LoginData _this;

  LoginData._();

  /// Allow for easy access to 'the Controller' throughout the application.
  static LoginData get con => _this;

  static bool get signUpActive => _this._signUpActive;
  static bool get signInActive => _this._signInActive;
  static bool get resetActive => _this._resetActive;

  static String get displayLogoTitle => "SLX Snitch";
  static String get displayLogoSubTitle => "Use your phone as an IoT sensor device";
  static String get displaySignInMenuButton => "SIGN IN";
  static String get displaySignUpMenuButton => "SIGN UP";
  static String get displayResetMenuButton => "FORGOT";
  static String get displayResetMenuFullButton => "Reset Password";
  static String get displayHintTextEmail => "Email";
  static String get displayHintTextPassword => "Password";
  static String get displayHintTextNewEmail => "Enter your Email";
  static String get displayHintTextNewPassword => "Enter a Password";
  static String get displaySignInEmailButton => "Sign in with Wappsto";
  static String get displaySeparatorText => "or";
  static String get displayErrorEmailLogIn => "Email or Password was incorrect. Please try again";
  static String get displayTermsText => "By signing in, you agree to our  ";
  static String get displayPrivacyText => "and that you have read our  ";
  static String get displayPoweredByText => "Powered by  ";

  static String get seluxitLink => "https://www.seluxit.com";
  static String get privacyLink => "https://www.seluxit.com/privacy";
  static String get termsLink => "https://www.seluxit.com/wp-content/uploads/2020/06/Cloud-Solutions-Terms-and-Conditions-Business.pdf";

  static void switchWappstoEnv(String env) {
    _this._prefs.then((SharedPreferences prefs) {
        print("Switching Wappsto Env to: $env");
        switch(env) {
          case "Production":
          prefs.setString("env", "");
          break;
          case "Staging":
          prefs.setString("env", "staging");
          break;
          case "QA":
          prefs.setString("env", "qa.");
          break;
          case "DEV":
          prefs.setString("env", "dev.");
          break;
        }

        setHost(prefs);
    });
  }

  static void changeToSignUp() {
    _this._signUpActive = true;
    _this._signInActive = false;
    _this._resetActive = false;
  }

  static void changeToSignIn() {
    _this._signUpActive = false;
    _this._signInActive = true;
    _this._resetActive = false;
  }

  static void changeToReset() {
    _this._signUpActive = false;
    _this._signInActive = false;
    _this._resetActive = true;
  }

  Future<bool> firebaseLogin(AuthCredential creds, BuildContext context) async {
    final authResult = await FirebaseAuth.instance.signInWithCredential(creds);
    final User user = authResult.user;

    if (user == null) {
      return false;
    }

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = FirebaseAuth.instance.currentUser;
    assert(user.uid == currentUser.uid);

    final String token = await user.getIdToken();

    if (token == null) {
      return false;
    }

    var session = await RestAPI.firebaseSession(token);
    if(session == null) {
      return false;
    }

    final SharedPreferences prefs = await _this._prefs;
    prefs.setString("session", session.id);

    _navigateToDashboard(context);

    return true;
  }

  static Future<bool> signInWithGoogle(BuildContext context) async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential creds = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    return _this.firebaseLogin(creds, context);
  }

  static Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();
    } catch(e) {
      print(e);
    }

    print("Google User Signed Out");
  }

  static Future<bool> signInWithFacebook(BuildContext context) async {
    print("Sign In With Facebook");
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          selectedUrl:
          'https://www.facebook.com/dialog/oauth?client_id=${_this.fbClientId}&redirect_uri=${_this.fbRedirectUrl}&response_type=token&scope=email,public_profile,',
        ),
        maintainState: true),
    );

    if (result != null) {
      try {
        await Firebase.initializeApp();
        final AuthCredential creds = FacebookAuthProvider.credential(result);
        return _this.firebaseLogin(creds, context);
      } catch (e) {
        print(e);
      }
    }

    return false;
  }

  static Future<String> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      var session = await RestAPI.fetchSession(email.trim(), password);
      final SharedPreferences prefs = await _this._prefs;
      prefs.setString("session", session.id);

      return null;
    } on RestException catch(e) {
      print(e);
      return e.result;
    } catch (e) {
      print(e);
      return "Wrong username/Password";
    }
  }

  static Future<String> resetWithEmail(email) async {
    String msg = await RestAPI.resetPassword(email.text.trim());
    if(msg == null) {
      return "Failed to reset password";
    } else {
      return msg;
    }
  }

  static Future _navigateToDashboard(BuildContext context) async {
    await Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.routeName, (_) => false);
  }

  static Future<String> tryToLogInUserViaEmail(BuildContext context, TextEditingController email, TextEditingController password) async {
    String res = await signInWithEmail(context, email.text, password.text);
    if(res == null) {
      email.clear();
      password.clear();

      _navigateToDashboard(context);
    }

    print(res);
    return res;
  }

  static Future<String> signUpWithEmailAndPassword(email, password) async {
    String msg = await RestAPI.signup(email.text.trim(), password.text);
    if(msg == null) {
      return "Failed to signup to Wappsto";
    } else {
      return msg;
    }
  }

  static Future logout() async {
    await signOutGoogle();
    SharedPreferences prefs = await _this._prefs;
    setHost(prefs);
  }
}
