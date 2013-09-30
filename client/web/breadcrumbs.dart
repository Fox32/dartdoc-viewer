import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-breadcrumbs")
class Breadcrumbs extends PolymerElement with ObservableMixin {
  Breadcrumbs() {
    new PathObserver(this, "viewer.currentPage").bindSync(
    (_) {
      notifyProperty(this, #crumbs);
    });
  }

  @observable get breadcrumbs => viewer.breadcrumbs;
  @observable get viewer => app.viewer;

  @observable crumbs() {
    var root = shadowRoot.query("#navbar");
    if (root == null) return;
    if (breadcrumbs.length < 2) return;
    var last = breadcrumbs.toList().removeLast();
    breadcrumbs.skip(1).takeWhile((x) => x != last).forEach(
        (x) => root.append(normalCrumb(x)));
    root.append(finalCrumb(last));
  }

  normalCrumb(item) =>
      new Element.html('<li><a class="btn-link" href="${item.linkHref}">'
        '${item.decoratedName}</a></li>', validator: validator);

  finalCrumb(item) =>
    new Element.html('<li class="active"><a class="btn-link">'
      '${item.decoratedName}</a></li>', validator: validator);

  get applyAuthorStyles => true;
}