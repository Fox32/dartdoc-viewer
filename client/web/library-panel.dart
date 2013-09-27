import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-library-panel")
class LibraryPanel extends PolymerElement {
  LibraryPanel() {
    print("Created library panel");
  }

}