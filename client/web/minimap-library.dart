library minimap_library;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap-library")
class MinimapElementLibrary extends MemberElement {
  MinimapElementLibrary() {
    new PathObserver(this, "viewer.currentPage").bindSync(
      (_) {
        notifyProperty(this, #operatorItems);
        notifyProperty(this, #variableItems);
        notifyProperty(this, #functionItems);
        notifyProperty(this, #classItems);
        notifyProperty(this, #typedefItems);
        notifyProperty(this, #errorItems);
        notifyProperty(this, #name);
        notifyProperty(this, #decoratedName);
        notifyProperty(this, #linkHref);
        notifyProperty(this, #currentLocation);
      });
  }

  get item => super.item;
  set item(x) => super.item = x;

  get viewer  => app.viewer;
  @observable get operatorItems => check(() => contents(page.operators));
  @observable get variableItems => check(() => contents(page.variables));
  @observable get functionItems => check(() => contents(page.functions));
  @observable get classItems => check(() => contents(page.classes));
  @observable get typedefItems => check(() => contents(page.typedefs));
  @observable get errorItems => check(() => contents(page.errors));

  contents(thing) => thing == null ? [] : thing.content;

  get page => viewer.currentPage;
  check(Function f) => page is Library ? f() : [];
  @observable get linkHref => check(() => page.linkHref);
  @observable get name => check(() => page.name);
  @observable get currentLocation => window.location;

  @observable decoratedName(thing) =>
      thing == null ? null : thing.decoratedName;

  hideShow(event, detail, target) {
    var list = shadowRoot.query("#" + target.hash.split("#").last);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
    } else {
      list.classes.add("in");
    }
  }

}