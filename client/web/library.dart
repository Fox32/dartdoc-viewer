import 'dart:async';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

import "dart:html";
import "dart:collection";

@CustomTag("dartdoc-library")
class LibraryElement extends MemberElement {
  LibraryElement() {
    item = defaultItem;
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #variables);
          notifyProperty(this, #operators);
          notifyProperty(this, #functions);
          notifyProperty(this, #clazzes);
          notifyProperty(this, #clazzesNotEmpty);
          notifyProperty(this, #typedefs);
          notifyProperty(this, #errors);
          notifyProperty(this, #addComment);
        });
  }

  set item(x) => super.item = x is Library ? x : defaultItem;

  get defaultItem => item = new Library.forPlaceholder({
      "name" : 'loading',
      "preview" : 'loading',
    });

  Category get variables => item.variables;

  Category get operators => item.operators;

  Category get functions => item.functions;

  Category get clazzes => item.classes;
  bool get clazzesNotEmpty =>
      clazzes == null ? false : clazzes.content.isNotEmpty;

  Category get typedefs => item.typedefs;

  Category get errors => item.errors;
}
