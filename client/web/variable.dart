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
  VariableElement() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #annotations);
        });
  }

  @observable bool isExpanded = true;
  @observable bool nothingToExpand = true;

  get item => super.item;
  set item(x) => super.item = (x is Variable ? x : null);

  void toggleExpand(event, handler, detail) {
    isExpanded = !isExpanded;
  }

  @observable get annotations =>
      item == null ? new AnnotationGroup([]) : item.annotations;

  bool get applyAuthorStyles => true;
}