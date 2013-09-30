import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-breadcrumb-item")
class BreadcrumbItem extends MemberElement {
  BreadcrumbItem() {
    item = defaultItem();
    new PathObserver(this, "item").bindSync(
    (_) {
      notifyProperty(this, #linkHref);
      notifyProperty(this, #decoratedName);
    });
  }

  set item(x) => super.item = item == null ? defaultItem() : x;

  defaultItem() => new Class.forPlaceholder("<p>loading</p>", "loading");

  @observable get linkHref => item.linkHref;
  @observable get decoratedName => item.decoratedName;
}