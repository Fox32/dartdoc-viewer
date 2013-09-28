
    import 'package:polymer/polymer.dart';
    import 'package:dartdoc_viewer/item.dart';
    import 'app.dart';
    import 'member.dart';
    import 'dart:html';

    /**
     * An HTML representation of a Category.
     *
     * Used as a placeholder for an CategoryItem object.
     */
     @CustomTag("dartdoc-category")
    class CategoryElement extends PolymerElement with ObservableMixin {

      CategoryElement() {
        new PathObserver(this, "category.name").bindSync(
            (_) {
              notifyProperty(this, #title);
              notifyProperty(this, #stylizedName);
            });
        new PathObserver(viewer, "isDesktop").bindSync(
            (_) {
              notifyProperty(this, #accordionStyle);
              notifyProperty(this, #accordionParent);
              notifyProperty(this, #divClass);
              notifyProperty(this, #divStyle);
            });
        new PathObserver(this, "category").bindSync(
            (_) {
              notifyProperty(this, #categoryContent);
              notifyProperty(this, #insertCategoryItems);
            });
      }

      @observable Container category;

      @observable String get title => category == null ? '' : category.name;

      @observable String get stylizedName =>
          category == null ? '' : category.name.replaceAll(' ', '-');

      @observable get categoryContent => category == null ? [] : category.content;

      @observable get accordionStyle => viewer.isDesktop ? '' : 'collapsed';
      @observable get accordionParent => viewer.isDesktop ? '' : '#accordion-grouping';

      @observable get divClass => viewer.isDesktop ? 'in' : 'collapse';
      @observable get divStyle => viewer.isDesktop ? 'auto' : '0px';

      var validator = new NodeValidatorBuilder()
    ..allowHtml5(uriPolicy: new SameProtocolUriPolicy())
    ..allowCustomElement("method-panel", attributes: ["item"])
    ..allowCustomElement("dartdoc-item", attributes: ["item"])
    ..allowCustomElement("dartdoc-variable", attributes: ["item"])
    ..allowCustomElement("dartdoc-category-interior", attributes: ["item"])
    ..allowTagExtension("method-panel", "div", attributes: ["item"]);

    @observable insertCategoryItems() {
        for (var item in categoryContent) {
           var node = createFragment(
               '<dartdoc-category-interior> item="{{item}}"></dartdoc-category-interior>',
               validator: validator);
           node.bind("item", item, "this");
           append(node);
        }

      }

      bool get applyAuthorStyles => true;
    }