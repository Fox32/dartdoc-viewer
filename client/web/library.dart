library library;

import 'dart:async';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-library")
class LibraryElement extends MemberElement {
  LibraryElement.created() : super.created() {
    item = defaultItem;
    new PathObserver(this, "item").bindSync(
    (_) {
      notifyProperty(this, #operators);
      notifyProperty(this, #variables);
      notifyProperty(this, #functions);
      notifyProperty(this, #classes);
      notifyProperty(this, #typedefs);
      notifyProperty(this, #errors);
      notifyProperty(this, #operatorsIsNotEmpty);
      notifyProperty(this, #variablesIsNotEmpty);
      notifyProperty(this, #functionsIsNotEmpty);
      notifyProperty(this, #classesIsNotEmpty);
      notifyProperty(this, #typedefsIsNotEmpty);
      notifyProperty(this, #errorsIsNotEmpty);
    });
  }

  @observable get operators =>
     item.operators == null ? [] : item.operators.content;
  @observable get variables =>
     item.variables == null ? [] : item.variables.content;
  @observable get functions =>
     item.functions == null ? [] : item.functions.content;
  @observable get classes => item.classes == null ? [] : item.classes.content;
  @observable get typedefs =>
      item.typedefs == null ? [] : item.typedefs.content;
  @observable get errors => item.errors == null ? [] : item.errors.content;

  @observable get operatorsIsNotEmpty => operators.isNotEmpty;
  @observable get variablesIsNotEmpty => variables.isNotEmpty;
  @observable get functionsIsNotEmpty => functions.isNotEmpty;
  @observable get classesIsNotEmpty => classes.isNotEmpty;
  @observable get typedefsIsNotEmpty => typedefs.isNotEmpty;
  @observable get errorsIsNotEmpty => errors.isNotEmpty;

  get item => super.item;
  set item(x) => super.item = x is Library ? x : defaultItem;

  get defaultItem => item = new Library.forPlaceholder({
      "name" : 'loading',
      "preview" : 'loading',
    });
}
