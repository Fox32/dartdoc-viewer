import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-class")
class ClassElement extends MemberElement {
  ClassElement() {
    item = new Class.forPlaceholder('loading', 'loading');
//    new PathObserver(this, "item").bindSync(
//        (_) {
//          notifyProperty(this, const Symbol('addComment'));
//        });
  }


  Class get item => super.item;

  Category get variables => item.variables;

  Category get operators => item.operators;

  Category get constructors => item.constructs;

  Category get methods => item.functions;

  AnnotationGroup get annotations => item.annotations;

  List<LinkableType> get interfaces => item.implements;

  List<LinkableType> get subclasses => item.subclasses;

  LinkableType get superClass => item.superClass;

  void showSubclass(event, detail, target) {
    document.query('#${item.name}-subclass-hidden').classes
        .remove('hidden');
    document.query('#${item.name}-subclass-button').classes.add('hidden');
  }

  bool get applyAuthorStyles => true;
}