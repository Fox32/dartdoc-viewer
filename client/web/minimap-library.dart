import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap-library")
class MinimapElementLibrary extends MemberElement {

  get operatorItems => check(() => page.operators.content);
  get variableItems => check(() => page.variables.content);
  get functionItems => check(() => page.functions.content);
  get classItems => check(() => page.classes.content);
  get typedefItems => check(() => page.typedefs.content);
  get errorItems => check(() => page.errors.content);

  get page => viewer.currentPage;
  check(Function f) => page is Library ? f() : [];


}