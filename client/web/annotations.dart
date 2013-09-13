import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';

@CustomTag("dartdoc-annotation")
class AnnotationElement extends PolymerElement with ObservableMixin {

  getAttributeNS(a, b) => null;
  @observable AnnotationGroup annotations;

  bool get applyAuthorStyles => true;
}