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
  VariableElement.created() : super.created() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #annotations);
        });
    style.setProperty('display', 'block');
  }

  get item => super.item;
  set item(x) => super.item = (x is Variable ? x : null);

  @observable get annotations =>
      item == null ? new AnnotationGroup([]) : item.annotations;
}