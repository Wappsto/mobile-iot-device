import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:mobile_iot_device/login_data.dart';
import 'package:url_launcher/url_launcher.dart';

final _emailKey = GlobalKey<FormState>();

TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _newEmailController = TextEditingController();
TextEditingController _newPasswordController = TextEditingController();

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  LoginScreen({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (context) =>
        SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 40.0),
              //Sets the main padding all widgets has to adhere to.
              child: LogInPage(),
            ),
          ),
        )
      ),
    );
  }

  static Future logout() async {
    await LoginData.logout();
  }
}

class _LogInPageState extends StateMVC<LogInPage> {
  _LogInPageState() : super(LoginData());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 30.0, left: 20.0, right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  LoginData.displayLogoTitle,
                  style: CustomTextStyle.title(context)
                ),
                Text(
                  LoginData.displayLogoSubTitle,
                  style: CustomTextStyle.subTitle(context),
                ),
              ],
          )),
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(220),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(top:10, left: 25.0, right: 25.0),
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  OutlineButton(
                    onPressed: () =>
                    setState(() => LoginData.changeToSignIn()),
                    borderSide: new BorderSide(
                      style: BorderStyle.none,
                    ),
                    child: new Text(LoginData.displaySignInMenuButton,
                      style: LoginData.signInActive
                      ? TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold)
                      : TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal)),
                  ),
                  OutlineButton(
                    onPressed: () =>
                    setState(() => LoginData.changeToSignUp()),
                    borderSide: BorderSide(
                      style: BorderStyle.none,
                    ),
                    child: Text(LoginData.displaySignUpMenuButton,
                      style: LoginData.signUpActive
                      ? TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold)
                      : TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal)),
                  ),
                  OutlineButton(
                    onPressed: () =>
                    setState(() => LoginData.changeToReset()),
                    borderSide: BorderSide(
                      style: BorderStyle.none,
                    ),
                    child: Text(LoginData.displayResetMenuButton,
                      style: LoginData.resetActive
                      ? TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold)
                      : TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal)),
                  )
                ],
              ),
            ),
          ),
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(170),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: LoginData.signInActive ? _showSignIn(context) : LoginData.signUpActive ? _showSignUp() : _showReset()),
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(932),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Text(
                  LoginData.displayPoweredByText,
                  style: CustomTextStyle.body(context),
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  child: Text(
                    "Seluxit A/S",
                    style: CustomTextStyle.link(context),
                  ),
                  onTap: () async {
                    if (await canLaunch(LoginData.seluxitLink)) {
                      await launch(LoginData.seluxitLink);
                    }
                  }
                ),
              ],
          )),
        ),
      ],
    );
  }

  Widget _showSignIn(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextFormField(
              key: _emailKey,
              style: TextStyle(color: Theme
                .of(context)
                .accentColor),
              controller: _emailController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Text is empty';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: LoginData.displayHintTextEmail,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme
                    .of(context)
                    .accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
              obscureText: false,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(10),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: true,
              style: TextStyle(color: Theme
                .of(context)
                .accentColor),
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: LoginData.displayHintTextPassword,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme
                    .of(context)
                    .accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: RaisedButton(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      LoginData.displaySignInEmailButton,
                      textAlign: TextAlign.center,
                      style: CustomTextStyle.button(context),
                    ),
                  )
                ],
              ),
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.all(12),
              onPressed: () async {
                _showLoading(context);
                String res = await LoginData.tryToLogInUserViaEmail(context, _emailController, _passwordController);
                if(res == null) {
                  print(_keyLoader.currentContext);
                } else {
                  _showMessage(
                    context,
                    'Signin',
                    res
                  );
                }
              },
            )
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                horizontalLine()
              ],
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Text(LoginData.displayTermsText,
                  style: CustomTextStyle.body(context),
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  child: Text(
                    "Terms",
                    style: CustomTextStyle.link(context),
                  ),
                  onTap: () async {
                    if (await canLaunch(LoginData.termsLink)) {
                      await launch(LoginData.termsLink);
                    }
                  }
                ),
                Text(LoginData.displayPrivacyText,
                  style: CustomTextStyle.body(context),
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  child: Text(
                    "Privacy Notice.",
                    style: CustomTextStyle.link(context),
                  ),
                  onTap: () async {
                    if (await canLaunch(LoginData.privacyLink)) {
                      await launch(LoginData.privacyLink);
                    }
                  }
                ),
              ],
            ),
          ),
        ),
        SignInButton(
          Buttons.Google,
          padding: EdgeInsets.all(4),
          onPressed: () async {
            LoginData.signInWithGoogle(context);
          },
        ),
        SizedBox(
          height: ScreenUtil().setHeight(20),
        ),
        SignInButton(
          Buttons.Facebook,
          padding: EdgeInsets.all(12),
          onPressed: () {
            LoginData.signInWithFacebook(context);
          },
        ),
      ],
    );
  }

  Widget _showSignUp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: false,
              style: CustomTextStyle.formField(context),
              controller: _newEmailController,
              decoration: InputDecoration(
                hintText: LoginData.displayHintTextNewEmail,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme
                    .of(context)
                    .accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(10),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: true,
              style: CustomTextStyle.formField(context),
              controller: _newPasswordController,
              decoration: InputDecoration(
                //Add the Hint text here.
                hintText: LoginData.displayHintTextNewPassword,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme
                    .of(context)
                    .accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: RaisedButton(
              child: Text(
                LoginData.displaySignUpMenuButton,
                style: CustomTextStyle.button(context),
              ),
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.all(12),
              onPressed: () async {
                _showLoading(context);
                _showMessage(
                  context,
                  'Signup',
                  await LoginData.signUpWithEmailAndPassword(
                    _newEmailController, _newPasswordController),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _showReset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: false,
              style: CustomTextStyle.formField(context),
              controller: _newEmailController,
              decoration: InputDecoration(
                //Add th Hint text here.
                hintText: LoginData.displayHintTextNewEmail,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme
                    .of(context)
                    .accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: RaisedButton(
              child: Text(
                LoginData.displayResetMenuFullButton,
                style: CustomTextStyle.button(context),
              ),
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.all(12),
              onPressed: () async {
                _showLoading(context);
                _showMessage(
                  context,
                  'Reset password',
                  await LoginData.resetWithEmail(_newEmailController)
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  void _showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return SimpleDialog(
          key: _keyLoader,
          children: <Widget>[
            Center(
              child: Container(
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      height:10,
                      width:10,
                    ),
                    Text("Please Wait!"),
                  ]
                ),
              ),
            ),
          ]
        );
      }
    );
  }

  Future<void> _showMessage(BuildContext context, String title, String message) async {
    Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();//close the dialoge

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget horizontalLine() =>
  Padding(
    padding: EdgeInsets.all(16.0),
    child: Container(
      width: ScreenUtil().setWidth(180),
      height: 1.0,
      color: Colors.white.withOpacity(0.2),
    ),
  );

  String validateEmail(String value) {
    print("validate");
    if (RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(value)) {
      return null;
    }
    return "Invalid Email";
  }
}

class LogInPage extends StatefulWidget {
  LogInPage({Key key}) : super(key: key);

  @protected
  @override
  State<StatefulWidget> createState() => _LogInPageState();
}

class CustomTextStyle {
  static TextStyle formField(BuildContext context) {
    return Theme
    .of(context)
    .textTheme
    .title
    .copyWith(
      fontSize: 18.0, fontWeight: FontWeight.normal, color: Colors.white);
  }

  static TextStyle title(BuildContext context) {
    return Theme
    .of(context)
    .textTheme
    .title
    .copyWith(
      fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white);
  }

  static TextStyle subTitle(BuildContext context) {
    return Theme
    .of(context)
    .textTheme
    .title
    .copyWith(
      fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey);
  }

  static TextStyle button(BuildContext context) {
    return Theme
    .of(context)
    .textTheme
    .title
    .copyWith(
      fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white);
  }

  static TextStyle body(BuildContext context) {
    return Theme
    .of(context)
    .textTheme
    .title
    .copyWith(
      fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);
  }

  static TextStyle link(BuildContext context) {
    return Theme
    .of(context)
    .textTheme
    .title
    .copyWith(
      fontSize: 14, color: Theme.of(context).accentColor);
  }
}
