import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a Variable.
 */
@CustomTag("variable-heading")
class VariableHeading extends MemberElement {

  Variable get item => super.item;

  String get getter => item.isGetter ? 'get' : '';

  Parameter get setterParameter => item.setterParameter;

  NestedType get type => item.type;

  String get name => item.name;
}