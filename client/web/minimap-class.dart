library minimap_class;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap-class")
class MinimapElementClass extends MemberElement {
  MinimapElementClass.created() : super.created() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #operatorItems);
          notifyProperty(this, #variableItems);
          notifyProperty(this, #constructorItems);
          notifyProperty(this, #functionItems);
          notifyProperty(this, #operators);
          notifyProperty(this, #variables);
          notifyProperty(this, #constructors);
          notifyProperty(this, #functions);
          notifyProperty(this, #operatorItemsIsNotEmpty);
          notifyProperty(this, #variableItemsIsNotEmpty);
          notifyProperty(this, #constructorItemsIsNotEmpty);
          notifyProperty(this, #functionItemsIsNotEmpty);
          notifyProperty(this, #page);
          notifyProperty(this, #shouldShowConstructors);
          notifyProperty(this, #shouldShowFunctions);
          notifyProperty(this, #shouldShowVariables);
          notifyProperty(this, #shouldShowOperators);
          notifyProperty(this, #name);
          notifyProperty(this, #currentLocation);
        });
  }

  @observable get operatorItems => check(() => page.operators.content);
  @observable get variableItems => check(() => page.variables.content);
  @observable get constructorItems => check(() => page.constructs.content);
  @observable get functionItems => check(() => page.functions.content);

  @observable get operators => check(() => page.operators);
  @observable get variables => check(() => page.variables);
  @observable get constructors => check(() => page.constructs);
  @observable get functions => check(() => page.functions);

  @observable get operatorItemsIsNotEmpty => _isNotEmpty(operators);
  @observable get variableItemsIsNotEmpty => _isNotEmpty(variables);
  @observable get constructorItemsIsNotEmpty => _isNotEmpty(constructors);
  @observable get functionItemsIsNotEmpty => _isNotEmpty(functions);

  _isNotEmpty(x) => x == null || page is! Class ? false : x.content.isNotEmpty;

  @observable get page => viewer.currentPage;
  check(Function f) => page is Class ? f() : [];

  get item => super.item;
  set item(x) => super.item = x;

  @observable get shouldShowConstructors => shouldShow((x) => x.constructors);
  @observable get shouldShowFunctions => shouldShow((x) => x.functions);
  @observable get shouldShowVariables => shouldShow((x) => x.variables);
  @observable get shouldShowOperators => shouldShow((x) => x.operators);

  shouldShow(Function f) => page is Class &&
      (f(page).hasNonInherited ||  viewer.isInherited);

  @observable get name => check(() => page.name);

  @observable get currentLocation => window.location.toString();

  hideShow(event, detail, target) {
    var list = shadowRoot.query("#minimap-" + target.hash.split("#").last);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
    } else {
      list.classes.add("in");
    }
  }
}