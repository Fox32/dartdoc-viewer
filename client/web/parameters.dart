import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-parameter")
class ParameterElement extends PolymerElement with ObservableMixin {
  @observable List<Parameter> parameters;

  // Required parameters.
  List<Parameter> get required =>
    parameters.where((parameter) => !parameter.isOptional).toList();

  // Optional parameters.
  List<Parameter> get optional =>
    parameters.where((parameter) => parameter.isOptional).toList();

  /// Adds [elements] to the tag with class [className].
  void addParameters(List<Parameter> elements, String className) {
    var location = getShadowRoot('dartdoc-parameter').query('.$className');
    var outerSpan = new SpanElement();
    elements.forEach((element) {
      // Since a dartdoc-annotation cannot be instantiated from Dart code,
      // the annotations must be built manually.
      element.annotations.annotations.forEach((annotation) {
        var anchor = new AnchorElement()
          ..text = '@${annotation.simpleType}'
          ..href = '#${annotation.location}';
        outerSpan.append(anchor);
        outerSpan.appendText(' ');
      });
      outerSpan.append(MemberElement.createInner(element.type));
      outerSpan.appendText(' ${element.decoratedName}');
      if (className == 'required' && optional.isNotEmpty ||
          element != elements.last) {
        outerSpan.appendText(', ');
      }
    });
    location.children.clear();
    location.children.add(outerSpan);
  }
  bool get applyAuthorStyles => true;
}