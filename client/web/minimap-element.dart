library minimap_element;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap")
class MinimapElement extends PolymerElement with ObservableMixin {
  MinimapElement() {
    new PathObserver(this, "viewer.isInherited").bindSync(
      (_) {
        notifyProperty(this, #shouldShow);
        notifyProperty(this, #addLink);
      });
  }

  @observable List<Item> items = [];

  get viewer => app.viewer;

  /// Creates a proper href String for an [Item].
  String link(linkItem) {
   var hash = linkItem.name == '' ? linkItem.decoratedName : linkItem.name;
   return '${viewer.currentPage.linkHref}#${viewer.toHash(hash)}';
  }

  @observable shouldShow(item) => !item.isInherited || viewer.isInherited;

  addLink(item) {
    if (!shouldShow(item)) return;
    var fragment = parent.createFragment(
        '<li><a href="#${link(item)}">${item.decoratedName}</a></li>');
    shadowRoot.append(fragment);
  }

  bool get applyAuthorStyles => true;

}