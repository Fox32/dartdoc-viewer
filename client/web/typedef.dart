library typedef;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartoc-typedef")
class TypedefElement extends MemberElement {
  TypedefElement() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #required);
          notifyProperty(this, #optional);
          notifyProperty(this, #annotations);
        });
  }


  Typedef get item => super.item;

  // Required parameters.
  @observable List<Parameter> get required =>
    item.parameters.where((parameter) => !parameter.isOptional).toList();

  // Optional parameters.
  @observable List<Parameter> get optional =>
    item.parameters.where((parameter) => parameter.isOptional).toList();

  @observable get annotations => item.annotations;
}