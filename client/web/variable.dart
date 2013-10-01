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

  @observable bool isExpanded = false;
  @observable bool nothingToExpand;

  set item(x) => super.item = (x is Variable ? x : null);

  inserted() {
    if (item == null) return;
    super.inserted();
    var index = item.comment.indexOf('</p>');
    if (index == -1) {
      isExpanded = true;
    } else {
      index = item.comment.indexOf('</p>', index + 1);
      if (index == -1) isExpanded = true;
      else isExpanded = false;
    }
    nothingToExpand = isExpanded;
  }

  void toggleExpand(event, handler, detail) {
    isExpanded = !isExpanded;
  }

  bool get applyAuthorStyles => true;
}