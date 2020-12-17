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

  Future<bool> save() async {
    return wappsto.update(this);
  }

  Future<bool> delete() async {
    return wappsto.delete(this);
  }

  Map<String, dynamic> toJson({bool children = true});
  String get url;
}
