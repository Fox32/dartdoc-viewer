library index;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'app.dart' as app;

@CustomTag("dartdoc-main")
class IndexElement extends PolymerElement with ObservableMixin {

  IndexElement() {
    new PathObserver(this, "viewer.currentPage").bindSync(
        (_) {
          notifyProperty(this, #viewer);
//          notifyProperty(this, #item);
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
}