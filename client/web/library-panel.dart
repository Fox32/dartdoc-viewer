import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-library-panel")
class LibraryPanel extends PolymerElement {
  get viewer => app.viewer;

  linkHref(library) => library == null ? '' : library.linkHref;

  createEntries() {
    var mainElement = query("#library-panel");
    if (viewer.homePage is! Library) return;
    for (var library in viewer.homePage.libraries) {
      var isFirst =
          library.decoratedName == viewer.breadcrumbs.first.decoratedName;
      var element =
          isFirst ? newElement(library, true) : newElement(library, false);
      mainElement.children.add(element);
    }
  }

  newElement(Library library, bool isActive) {
    var html = '<a href="#{library.linkHref}" class="list-group-item'
        '${isActive ? ' active' : ''}">'
        '${library.decoratedName}</a>';
    new Element.html(html, validator: validator);
  }
}