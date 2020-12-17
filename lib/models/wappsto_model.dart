import 'dart:convert';
import 'package:slx_snitch/wappsto.dart';

abstract class WappstoModel {
  WappstoModel parent;

  WappstoModel(this.parent);

  String toJsonString({bool children = true}) {
    return jsonEncode(toJson(children: children));
  }

  Wappsto get wappsto {
    return parent.wappsto;
  }

  Map<String, dynamic> toJson({bool children = true});
  Future<bool> save();
  Future<bool> delete();
  String get url;
}
