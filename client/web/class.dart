library class_;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-class")
class ClassElement extends MemberElement {
  ClassElement() {
    item = new Class.forPlaceholder('loading', 'loading');
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #variables);
          notifyProperty(this, #operators);
          notifyProperty(this, #constructors);
          notifyProperty(this, #methods);
          notifyProperty(this, #annotations);
          notifyProperty(this, #interfaces);
          notifyProperty(this, #subclasses);
          notifyProperty(this, #superClass);
          notifyProperty(this, #nameWithGeneric);
          notifyProperty(this, #addComment);
        });
  }

  // TODO(alanknight): This is a workaround for bindings firing even when
  // their surrounding test isn't true. So ignore values of the wrong type
  // temporarily.
  set item(x) => super.item = (x is Class) ? x : item;

  @observable Class get item => super.item;

  @observable Category get variables => item.variables;

  @observable Category get operators => item.operators;

  @observable Category get constructors => item.constructs;

  @observable Category get methods => item.functions;

  @observable AnnotationGroup get annotations => item.annotations;

  @observable List<LinkableType> get interfaces => item.implements;

  @observable List<LinkableType> get subclasses => item.subclasses;

  @observable LinkableType get superClass => item.superClass;

  void showSubclass(event, detail, target) {
    document.query('#${item.name}-subclass-hidden').classes
        .remove('hidden');
    document.query('#${item.name}-subclass-button').classes.add('hidden');
  }

  bool get applyAuthorStyles => true;

  @observable String get nameWithGeneric => item.nameWithGeneric;

}