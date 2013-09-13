import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';

import 'app.dart' as app;

/**
 * An HTML representation of a page
 */
@CustomTag("dartdoc-page")
class PageElement extends PolymerElement {
  @observable Home home;

  // We need this because we can't write {{app.viewer...}} in polymer.
  get viewer => app.viewer;

  bool get applyAuthorStyles => true;
}