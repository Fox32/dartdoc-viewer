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
        });
  }

  static const method = '''
    <method-panel class="panel hidden-sm" item="{{item}}">
    <method-panel> <!--  ### What is this for?
    <dartdoc-item class="visible-sm panel" item="{{item}}">
    </dartdoc-item> -->''';
  static const variable = '''
        <dartdoc-variable item="{{item}}" class="panel">
        </dartdoc-variable>''';
  static const otherwise = '''
      <dartdoc-item class="panel" item="{{item}}"></dartdoc-item>''';

  @observable get variableShouldShow =>
    item is Variable && (!item.isInherited || viewer.isInherited);
  @observable get methodShouldShow =>
    item is Method && (!item.isInherited || viewer.isInherited);



   set item(x) {
     if (x == null)
       print("whoops");
     print(x);
          super.item = x;
     print(interiorElementString());
//     interiorElements;

   }

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

//     children.last.xtag.attributes["item"] = "{{item}}";
//     shadowRoot.children.add(new Element.html("<i>$item</i>", validator: validator));
//   }
//
//   <template if="item is Item && item is! Variable && item is! Method}}">
//      <dartdoc-item class="panel" item="item"></dartdoc-item>
//    </template>
//
//    <template if="item is Variable && (!item.isInherited || viewer.isInherited)}}">
//        <dartdoc-variable item="{{item}}" class="panel">
//        </dartdoc-variable>
//      </template>
//
//  <template if="{{item is Method}} && (!item.isInherited || viewer.isInherited)}}">
//    <div is="method-panel" class="panel hidden-sm" item="{{item}}">
//    </div> <!--  ### What is this for?
//    <dartdoc-item class="visible-sm panel" item="{{item}}">
//    </dartdoc-item> -->
//  </template>
}