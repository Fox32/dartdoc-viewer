
    import 'package:polymer/polymer.dart';
    import 'package:dartdoc_viewer/item.dart';
    import 'app.dart' as app;
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
              notifyProperty(this, const Symbol('title'));
              notifyProperty(this, const Symbol('stylizedName'));
            });
      }
      @observable Container category;

      String get title => category.name;

      String get stylizedName => category.name.replaceAll(' ', '-');

      bool get applyAuthorStyles => true;
    }