import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slx_snitch/main.dart';

typedef InitCallback = void Function(SharedPreferences);

class SplashApp extends StatefulWidget {
  final InitCallback onInitializationComplete;

  const SplashApp({
      Key key,
      @required this.onInitializationComplete,
  }) : super(key: key);

  @override
  _SplashAppState createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    widget.onInitializationComplete(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: RaisedButton(
          child: Text('retry'),
          onPressed: () => main(),
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 10,
        backgroundColor: Theme.of(context).primaryColor
      ),
    );
  }
}
