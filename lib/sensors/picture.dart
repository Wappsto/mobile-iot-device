import 'package:flutter/material.dart';

import 'package:slx_snitch/models/configuration.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class Picture extends Configuration {
  String picture;

  Picture() {
    icon = Icons.camera_alt;
    name = "Picture";

    addValue('Picture');
  }

  void start() {
    text = "Take Picture";
    call();

    if(picture != null) {
      update(0, picture);
    }
  }

  Value createValue(Device device, String name) {
    Value value = device.createBlobValue(name, 'image', 10000);
    value.createState(StateType.Report, data: "");

    return value;
  }
}
