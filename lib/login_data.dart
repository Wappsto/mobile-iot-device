import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_iot_device/dashboard.dart';
import 'package:mobile_iot_device/rest.dart';
import 'package:mobile_iot_device/utils/facebook_login_view.dart';

class LoginData extends ControllerMVC {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final String fbClientId = "2562179333883383";
  final String fbRedirectUrl = "https://wappsto-941e8.firebaseapp.com/__/auth/handler";

  final GoogleSignIn googleSignIn = GoogleSignIn();

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

  static String get displayLogoTitle => "SLX Mobile IoT Device";
  static String get displayLogoSubTitle => "Powered by Wappsto";
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
  static String get displayTermsText => "By signing in, you agree to our Terms and that you have read our Privacy Notice.";

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

  Future<void> firebaseLogin(AuthCredential creds, BuildContext context) async {
    final authResult = await FirebaseAuth.instance.signInWithCredential(creds);
    final User user = authResult.user;

    if (user == null) {
      return;
    }

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = FirebaseAuth.instance.currentUser;
    assert(user.uid == currentUser.uid);

    final String token = await user.getIdToken();

    if (token == null) {
      return;
    }

    var session = await firebaseSession(token);
    if(session == null) {
      return;
    }

    final SharedPreferences prefs = await _this._prefs;
    prefs.setString("session", session.id);

    _navigateToDashboard(context);
  }

  static Future<void> signInWithGoogle(BuildContext context) async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await _this.googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential creds = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    _this.firebaseLogin(creds, context);
  }

  static Future<void> signOutGoogle() async {
    try {
      await _this.googleSignIn.signOut();
    } catch(e) {
      print(e);
    }

    print("Google User Signed Out");
  }

  static Future<void> signInWithFacebook(BuildContext context) async {
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
        _this.firebaseLogin(creds, context);
      } catch (e) {
        print(e);
      }
    }
  }

  static Future<String> signInWithEmail(context, email, password) async {
    try {
      var session = await fetchSession(email, password);
      final SharedPreferences prefs = await _this._prefs;
      prefs.setString("session", session.id);

      return null;
    } catch (e) {
      print(e);
      return "Wrong username/Password";
    }
  }

  static void signUpWithEmailAndPassword(email, password) async {

  }

  static void resetWithEmail(email) async {

  }

  static Future _navigateToDashboard(context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
  }

  static Future tryToLogInUserViaEmail(context, email, password) async {
    String res = await signInWithEmail(context, email, password);
    if(res == null) {
      _navigateToDashboard(context);
    } else {
      print(res);
    }
  }

  static Future tryToSignUpWithEmail(email, password) async {
    if (await tryToSignUpWithEmail(email, password) == true) {
      //TODO Display success message or go to Login screen
    } else {
      //TODO Display error message and stay put.
    }
  }

  static Future logout() async {
    await signOutGoogle();
  }
}
