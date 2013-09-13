import 'dart:async';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-library")
class LibraryElement extends MemberElement {

  Category get variables => item.variables;

  Category get operators => item.operators;

  Category get functions => item.functions;

  Category get clazzes => item.classes;

  Category get typedefs => item.typedefs;

  Category get errors => item.errors;
}