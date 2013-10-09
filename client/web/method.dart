library method;

import 'app.dart';
import 'member.dart';
import 'package:polymer/polymer.dart';

@CustomTag("dartdoc-method")
class DartdocMethod extends MethodElement {
  DartdocMethod() {
    new PathObserver(this, "!item.isConstructor").bindSync(
        (_) {
          if (!item.isConstructor) {
            createType(item.type, 'dartdoc-method', 'type');
          }
        });
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #annotations);
          notifyProperty(this, #modifiers);
          notifyProperty(this, #shouldShowMethodComment);
        });
  }

  get item => super.item;
  set item(x) => super.item = x;

  @observable String get modifiers => constantModifier + abstractModifier + staticModifier;
  get constantModifier => item.isConstant ? 'const' : '';
  get abstractModifier => item.isAbstract ? 'abstract' : '';
  get staticModifier => item.isStatic ? 'static' : '';
  @observable get annotations => item.annotations;
  @observable get shouldShowMethodComment =>
    item != null && item.comment != '<span></span>';
}