import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'member.dart';

@CustomTag("dartdoc-homepage")
class HomeElement extends MemberElement {
  HomeElement() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #libraries);
        });
  }

  @observable
  get libraries => item == null ? [] : item.libraries;

}