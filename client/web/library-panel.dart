import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-library-panel")
class LibraryPanel extends PolymerElement with ObservableMixin {
  LibraryPanel() {
    new PathObserver(viewer, "currentPage").bindSync(
    (_) {
      notifyProperty(this, #createEntries);
    });

  }

  get viewer => app.viewer;

  linkHref(library) => library == null ? '' : library.linkHref;

  @observable createEntries() {
    var mainElement = shadowRoot.query("#library-panel");
    if (mainElement == null) return;
    for (var library in viewer.homePage.libraries) {
      var isFirst =
          library.decoratedName == viewer.breadcrumbs.first.decoratedName;
      var element =
          isFirst ? newElement(library, true) : newElement(library, false);
      mainElement.append(element);
    }
  }

  newElement(Library library, bool isActive) {
    var html = '<a href="#${linkHref(library)}" class="list-group-item'
        '${isActive ? ' active' : ''}">'
        '${library.decoratedName}</a>';
    return new Element.html(html, validator: validator);
  }
}