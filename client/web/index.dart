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
          notifyProperty(this, const Symbol('viewer'));
        });
  }

  get pageContentClass {
    if (!viewer.isDesktop) return '';
    if (viewer.isPanel) return 'margin-left';
    if (viewer.isMinimap) return 'margin-right';
    return '';
  }

  @observable get viewer => app.viewer;
  @observable var things = ["1", "2", "3"];
  @observable get pageNameSeparator => decoratedName == '' ? '' : ' - ';
  @observable get decoratedName =>
      viewer.currentPage == null ? '' : viewer.currentPage.decoratedName;
  togglePanel(event, detail, target) => viewer.togglePanel();
  toggleInherited(event, detail, target) => viewer.toggleInherited();
  toggleMinimap(event, detail, target) => viewer.toggleMinimap();

  get applyAuthorStyles => true;
}