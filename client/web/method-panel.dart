library method_panel;

import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("method-panel")
class MethodPanel extends MethodElement {
  MethodPanel() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #annotations);
          notifyProperty(this, #modifiers);
        });
  }
  @observable bool isExpanded = true;
  @observable bool nothingToExpand = true;

  void toggleExpand(event, detail, target) {
    isExpanded = !isExpanded;
  }

  @observable String get modifiers => constantModifier + abstractModifier + staticModifier;
  @observable get constantModifier => item.isConstant ? 'const' : '';
  @observable get abstractModifier => item.isAbstract ? 'abstract' : '';
  @observable get staticModifier => item.isStatic ? 'static' : '';
  @observable get annotations => item.annotations;
}