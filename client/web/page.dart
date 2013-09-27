import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';

import 'app.dart' as app;

/**
 * An HTML representation of a page
 */
@CustomTag("dartdoc-page")
class PageElement extends PolymerElement with ObservableMixin {
  @observable Home home;

  PageElement() {
    new PathObserver(viewer, "currentPage").bindSync(
        (_) {
          notifyProperty(this, #currentPage);
          notifyProperty(this, #currentPageIsLibrary);
          notifyProperty(this, #currentPageIsMethod);
          notifyProperty(this, #currentPageIsClass);
          notifyProperty(this, #currentPageIsTypedef);
          notifyProperty(this, #isHome);
        });
    new PathObserver(viewer, "homePage").bindSync(
        (_) {
          notifyProperty(this, #hasHomePage);
        });
  }

  @observable get isHome => viewer.currentPage is Home;
  @observable get hasHomePage => viewer.homePage != null;

  @observable get currentPageIsLibrary => viewer.currentPage is Library;
  @observable get currentPageIsMethod => viewer.currentPage is Method;
  @observable get currentPageIsClass => viewer.currentPage is Class;
  @observable get currentPageIsTypedef => viewer.currentPage is Typedef;

  @observable get currentPage => viewer.currentPage;

  get viewer => app.viewer;
  bool get applyAuthorStyles => true;
}