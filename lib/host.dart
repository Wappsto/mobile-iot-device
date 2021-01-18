import 'package:shared_preferences/shared_preferences.dart';

String host = "wappsto.com";

void setHost(SharedPreferences prefs) {
  String env = prefs.getString("env");
  if(env == null) {
    env = "";
  }
  host = "${env}wappsto.com";
  print("Changed host to $host");
}
