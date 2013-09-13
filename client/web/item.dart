import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';

import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a Item.
 *
 * Used as a placeholder for an CategoryItem object.
 */
 @CustomTag("dartdoc-item")
class ItemElement extends MemberElement {

  String get title => item.decoratedName;
}