library annotations;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';

@CustomTag("dartdoc-annotation")
class AnnotationElement extends PolymerElement with ObservableMixin {
  AnnotationElement() {
    new PathObserver(this, "annotations").bindSync(
        (_) {
          notifyProperty(this, #addAnnotations);
        });
  }

  @observable AnnotationGroup annotations;

  bool get applyAuthorStyles => true;

  addAnnotations() {
    if (annotations == null || annotations.annotations.isEmpty) return '';
    var out = new StringBuffer();
    for (var annotation in annotations.annotations) {
      out.write('<i><a href="${annotation.link.location}">'
          '${annotation.link.simpleType}</a></i>');
      var hasParams = annotation.parameters.isNotEmpty;
      if (hasParams) out.write("(");
      out.write(annotation.parameters.join(",&nbsp;"));
      if (hasParams) out.write(")");
    }
    if (annotations.supportedBrowsers.isNotEmpty) {
      out.write("<br/><i>Supported on:");
      out.write(annotations.supportedBrowsers.join(",&nbsp;"));
      out.write("</i><br/>");
    }
    append(createFragment(out.toString(), validator: validator));
  }


}