library index;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'app.dart' as app;
import 'dart:html';

@CustomTag("dartdoc-main")
class IndexElement extends PolymerElement with ObservableMixin {

  IndexElement() {
    new PathObserver(this, "viewer.currentPage").bindSync(
        (_) {
          notifyProperty(this, #viewer);
          notifyProperty(this, #shouldShowLibraryMinimap);
          notifyProperty(this, #shouldShowClassMinimap);
          notifyProperty(this, #crumbs);
        });
  }

  get pageContentClass {
    if (!viewer.isDesktop) return '';
    if (viewer.isPanel) return 'margin-left';
    if (viewer.isMinimap) return 'margin-right';
    return '';
  }

  query(String selectors) => shadowRoot.query(selectors);

  searchSubmitted() {
    query('#nav-collapse-button').classes.add('collapsed');
    query('#nav-collapse-content').classes.remove('in');
    query('#nav-collapse-content').classes.add('collapse');
  }

  @observable get item => viewer.currentPage.item;
  @observable get viewer => app.viewer;
  @observable get pageNameSeparator => decoratedName == '' ? '' : ' - ';
  @observable get decoratedName =>
      viewer.currentPage == null ? '' : viewer.currentPage.decoratedName;
  togglePanel(event, detail, target) => viewer.togglePanel();
  toggleInherited(event, detail, target) => viewer.toggleInherited();
  toggleMinimap(event, detail, target) => viewer.toggleMinimap();

  get applyAuthorStyles => true;

  @observable get shouldShowLibraryMinimap =>
      viewer.currentPage is Library && viewer.isMinimap;

  get shouldShowClassMinimap => viewer.currentPage is Class && viewer.isMinimap;

  get breadcrumbs => viewer.breadcrumbs;

  @observable crumbs() {
    var root = shadowRoot.query("#navbar");
    if (root == null) return;
    if (breadcrumbs.length < 2) return;
    root.children.clear();
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

}