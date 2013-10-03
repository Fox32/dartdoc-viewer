library minimap_class;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap-class")
class MinimapElementClass extends MemberElement {
  get operatorItems => check(() => page.operators.content);
  get variableItems => check(() => page.variables.content);
  get constructorItems => check(() => page.constructs.content);
  get functionItems => check(() => page.functions.content);

  get page => viewer.currentPage;
  check(Function f) => page is Class ? f() : [];

  get item => super.item;
  set item(x) => super.item = x;

  get shouldShowConstructors => shouldShow((x) => x.constructors);
  get shouldShowFunctions => shouldShow((x) => x.functions);
  get shouldShowVariables => shouldShow((x) => x.variables);
  get shouldShowOperators => shouldShow((x) => x.operators);

  shouldShow(Function f) => page is Class &&
      (f(page).hasNonInherited ||  viewer.isInherited);

  @observable get name => check(() => page.name);

  @observable String constantLink(String tail) {
    return '${window.location.toString().split("#").first}#$tail';
  }
}