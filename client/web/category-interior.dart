import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-category-interior")
class CategoryInterior extends MemberElement {

  CategoryInterior() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #variableShouldShow);
          notifyProperty(this, #methodShouldShow);
          notifyProperty(this, #itemShouldShow);
        });
  }

  @observable get variableShouldShow =>
    item is Variable && (!item.isInherited || viewer.isInherited);
  @observable get methodShouldShow =>
    item is Method && (!item.isInherited || viewer.isInherited);
  @observable get itemShouldShow =>
    item is Item && item is! Variable && item is! Method;

   String interiorElementString() {
     if (item == null)
       return "<p>#### Please wait</p>";
     if (item is Method && (!item.isInherited || viewer.isInherited)) return method;
     if (item is Variable && (!item.isInherited || viewer.isInherited)) return variable;
     return otherwise;
   }

   var validator = new NodeValidatorBuilder()
    ..allowHtml5(uriPolicy: new SameProtocolUriPolicy())
    ..allowCustomElement("method-panel", attributes: ["item"])
    ..allowCustomElement("dartdoc-item", attributes: ["item"])
    ..allowCustomElement("dartdoc-variable", attributes: ["item"])
    ..allowTagExtension("method-panel", "div", attributes: ["item"]);

//   get interiorElements {
//     var text = interiorElementString();
//     if (text != null) {
//       setInnerHtml(text, validator: validator);
//     }

}