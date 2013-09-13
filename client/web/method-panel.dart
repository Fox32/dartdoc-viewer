import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("method-panel")
class MethodPanel extends MethodElement {
  @observable bool isExpanded = false;
  @observable bool nothingToExpand;

  inserted() {
    super.inserted();
    var index = item.comment.indexOf('</p>');
    if (index == -1) {
      isExpanded = !isInherited;
    } else {
      index = item.comment.indexOf('</p>', index + 1);
      if (index == -1) isExpanded = true;
      else isExpanded = false;
    }
    nothingToExpand = isExpanded;
  }

  void toggleExpand(event, detail, target) {
    isExpanded = !isExpanded;
  }
}