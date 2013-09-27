import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap-class")
class MinimapElementClass extends MemberElement {
  get operatorItems => check(() => page.operators.content);
  get variableItems => check(() => page.variables.content);
  get constructorItems => check(() => page.constructs.content);
  get functionItems => check(() => page.functions.content);

  get page => viewer.currentPage;
  List check(Function f) => page is Class ? f() : [];
}