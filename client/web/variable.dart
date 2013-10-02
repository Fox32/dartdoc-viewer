library variable;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a Variable.
 */
@CustomTag("dartdoc-variable")
class VariableElement extends InheritedElement {

  @observable bool isExpanded = true;
  @observable bool nothingToExpand = true;

  set item(x) => super.item = (x is Variable ? x : null);

  void toggleExpand(event, handler, detail) {
    isExpanded = !isExpanded;
  }

  bool get applyAuthorStyles => true;
}