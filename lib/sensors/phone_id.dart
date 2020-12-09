import 'package:flutter/material.dart';
import 'package:slx_snitch/utils/phone_info.dart';
import 'package:slx_snitch/models/configuration.dart';
import 'package:slx_snitch/models/device.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/models/state.dart';

class PhoneID extends Configuration {
  String phoneId = "";

  PhoneID() {
    icon = Icons.phonelink_setup;
    name = "Phone ID";

    valueName.add('Phone ID');

    PhoneInfo.getPlatformState().then((deviceData) {
        phoneId = deviceData['phone_id'];
    });
  }

  void start() {
    if(value[0] != null) {
      value[0].update(phoneId);
    }

    text = phoneId;
    call();
  }

  Value createValue(Device device, String name) {
    Value value = device.createStringValue(name, 'id', 50);
    value.createState(StateType.Report, data: phoneId);

    return value;
  }
}
