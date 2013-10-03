library parameters;

import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-parameter")
class ParameterElement extends PolymerElement {
  ParameterElement() {
    new PathObserver(this, "parameters").bindSync(
        (_) {
          notifyProperty(this, #required);
          notifyProperty(this, #optional);
          notifyProperty(this, #optionalOpeningDelimiter);
          notifyProperty(this, #optionalClosingDelimiter);
        });
  }

  @observable List<Parameter> parameters = const [];

  // Required parameters.
  @observable List<Parameter> get required =>
    parameters.where((parameter) => !parameter.isOptional).toList();

  // Optional parameters.
  @observable List<Parameter> get optional =>
    parameters.where((parameter) => parameter.isOptional).toList();

  @observable get optionalOpeningDelimiter =>
      optional.first.isNamed ? '{' : '[';

  @observable get optionalClosingDelimiter =>
      optional.first.isNamed ? '}' : ']';

  /// Adds [elements] to the tag with class [className].
  void addParameters(List<Parameter> elements, String className) {
    if (elements.isEmpty) return;
    var location = shadowRoot.query('.$className');
    if (location == null) return;
    var outerSpan = new SpanElement();
    if (className == 'optional') {
      outerSpan.appendText(optionalOpeningDelimiter);
    }
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
    if (className == 'optional') {
      outerSpan.appendText(optionalClosingDelimiter);
    }
    location.children.clear();
    location.children.add(outerSpan);
  }
  bool get applyAuthorStyles => true;
}