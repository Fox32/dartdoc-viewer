import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-breadcrumbs")
class Breadcrumbs extends PolymerElement {

  get viewer => app.viewer;

  get applyAuthorStyles => true;
}