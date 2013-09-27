
    import 'package:polymer/polymer.dart';
    import 'package:dartdoc_viewer/item.dart';
    import 'app.dart';
    import 'member.dart';

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
            });
      }

      @observable Container category;

      String get title => category == null ? '' : category.name;

      String get stylizedName =>
          category == null ? '' : category.name.replaceAll(' ', '-');

      get categoryContent => category == null ? [] : category.content;

      get accordionStyle => viewer.isDesktop ? '' : 'collapsed';
      get accordionParent => viewer.isDesktop ? '' : '#accordion-grouping';

      get divClass => viewer.isDesktop ? 'in' : 'collapse';
      get divStyle => viewer.isDesktop ? 'auto' : '0px';

      bool get applyAuthorStyles => true;
    }