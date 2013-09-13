import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartoc-typedef")
class TypedefElement extends MemberElement {
  Typedef get item => super.item;

  // Required parameters.
  List<Parameter> get required =>
    item.parameters.where((parameter) => !parameter.isOptional).toList();

  // Optional parameters.
  List<Parameter> get optional =>
    item.parameters.where((parameter) => parameter.isOptional).toList();
}