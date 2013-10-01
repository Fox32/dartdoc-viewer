library debug;

import 'package:polymer/polymer.dart';
import 'app.dart';

@CustomTag("dartdoc-debug")
class DebugElement extends PolymerElement with ObservableMixin {
  DebugElement() {
    print("Created Debug Element");
    print("Viewer.currentPage = ${viewer.currentPage}");
    new PathObserver(viewer, "currentPage").bindSync(
        (_) {
          notifyProperty(this, #currentPage);
          notifyProperty(this, #timestamp);
        });
  }

  @observable get currentPage => viewer.currentPage;
  get timestamp => new DateTime.now().toString();
}