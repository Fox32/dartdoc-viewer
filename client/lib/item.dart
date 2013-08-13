library category_item;

import 'dart:async';
import 'dart:html';

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:web_ui/web_ui.dart';
import 'package:yaml/yaml.dart';

// TODO(tmandel): Don't hardcode in a path if it can be avoided.
const docsPath = '../../docs/';

/**
 * Anything that holds values and can be displayed.
 */
@observable 
class Container {
  String name;
  String comment = '<span></span>';
  
  Container(this.name, [this.comment]);
}

// Wraps a comment in span element to make it a single HTML Element.
String _wrapComment(String comment) {
  if (comment == null) comment = '';
  return '<span>$comment</span>';
}

/// Returns the qualified name of [qualifiedName]'s owner.
String ownerName(String qualifiedName) {
  var index = qualifiedName.lastIndexOf('.');
  return index != -1 ? qualifiedName.substring(0, index) : '';
}

/**
 * A [Container] that contains other [Container]s to be displayed.
 */
class Category extends Container {
  
  List<Container> content = [];
  Set<String> memberNames = new Set<String>();
  int inheritedCounter = 0;
  int memberCounter = 0;
  
  Category.forClasses(List<Map> classes, String name, 
      {bool isAbstract: false}) : super(name) {
    if (classes != null) {
      classes.forEach((clazz) => 
        content.add(new Class.forPlaceholder(clazz['name'], clazz['preview'])));
    }
  }
  
  Category.forVariables(Map variables, Map getters, Map setters) 
      : super('Properties') {
    if (variables != null) {
      variables.keys.forEach((key) {
        memberNames.add(key);
        memberCounter++;
        content.add(new Variable(variables[key]));
      });
    }
    if (getters != null) {
      getters.keys.forEach((key) {
        memberNames.add(key);
        memberCounter++;
        content.add(new Variable(getters[key], isGetter: true));
      });
    }
    if (setters != null) {
      setters.keys.forEach((key) {
        memberNames.add(key);
        memberCounter++;
        content.add(new Variable(setters[key], isSetter: true));
      });
    }
  }
  
  Category.forFunctions(Map yaml, String name, {bool isConstructor: false, 
      String className: '', bool isOperator: false}) : super(name) {
    if (yaml != null) {
      yaml.keys.forEach((key) {
        memberNames.add(key);
        memberCounter++;
        content.add(new Method(yaml[key], isConstructor: isConstructor, 
            className: className, isOperator: isOperator));
      });
    }
  }
  
  Category.forTypedefs(Map yaml) : super ('Typedefs') {
    if (yaml != null) {
      yaml.keys.forEach((key) => content.add(new Typedef(yaml[key])));
    }
  }
  
  /// Adds [item] to [destination] if [item] has not yet been defined within
  /// [destination] and handles inherited comments.
  void addInheritedItem(Class clazz, Item item) {
    if (!memberNames.contains(item.name)) {
      memberCounter++;
      inheritedCounter++;
      pageIndex['${clazz.qualifiedName}.${item.name}'] = item;
      content.add(item);
    } else {
      var member = content.firstWhere((innerItem) => 
          innerItem.name == item.name);
      member.addInheritedComment(item);
    }
  }
  
  bool get hasNonInherited => inheritedCounter < memberCounter;
  
}

/**
 * A [Container] synonymous with a page.
 */
class Item extends Container {
  /// A list of [Item]s representing the path to this [Item].
  List<Item> path = [];
  String qualifiedName;
  
  Item(String name, this.qualifiedName, [String comment]) 
      : super(name, comment);
  
  /// [Item]'s name with its properties properly appended. 
  String get decoratedName => name;
  
  /// Adds this [Item] to [pageIndex] and updates all necessary members.
  void addToHierarchy() {
    pageIndex[qualifiedName] = this;
  }
  
  /// Adds the comment from [item] to [this].
  void addInheritedComment(Item item) {}
}

/// Sorts each inner [List] by qualified names.
void _sort(List<List<Item>> items) {
  items.forEach((item) {
    item.sort((Item a, Item b) =>
      a.qualifiedName.compareTo(b.qualifiedName));
  });
}

/**
 * An [Item] containing all of the [Library] and [Placeholder] objects.
 */
class Home extends Item {
  
  /// All libraries being viewed from the homepage.
  List<Item> libraries = [];
  
  /// The constructor parses the [libraries] input and constructs
  /// [Placeholder] objects to display before loading libraries.
  Home(List libraries) : super('Dart API Reference', 'home') {
    for (String library in libraries) {
      libraryNames[library] = library.replaceAll('.', '-');
      this.libraries.add(new Library.forPlaceholder(library));
    };
    _sort([this.libraries]);
  }
  
  /// Returns the [Item] representing [libraryName].
  // TODO(tmandel): Stop looping through 'libraries' so much. Possibly use a 
  // map from library names to their objects.
  Item itemNamed(String libraryName) {
    return libraries.firstWhere((lib) => libraryNames[lib.name] == libraryName,
        orElse: () => null);
  }
}

/// Runs through the member structure and creates path information.
void buildHierarchy(Item page, Item previous) {
  if (page.path.isEmpty) {
    page.path
      ..addAll(previous.path)
      ..add(page);
  }
  page.addToHierarchy();
}

/**
 * An [Item] that is lazily loaded.
 */
abstract class LazyItem extends Item {
  
  bool isLoaded = false;
  
  LazyItem(String qualifiedName, String name, [String comment]) 
      : super(name, qualifiedName, comment);
  
  /// Loads this [Item]'s data and populates all fields.
  Future load() {
    var data = retrieveFileContents('$docsPath$qualifiedName.yaml');
    return data.then((response) {
      var yaml = loadYaml(response);
      loadValues(yaml);
      buildHierarchy(this, this);
    });
  }
  
  /// Populates all of this [Item]'s fields.
  void loadValues(Map yaml);
}

/**
 * An [Item] that describes a single Dart library.
 */
class Library extends LazyItem {
  
  Category classes;
  Category errors;
  Category typedefs;
  Category variables;
  Category functions;
  Category operators;

  /// Creates a [Library] placeholder object with null fields.
  Library.forPlaceholder(String location) : super(location, location);
  
  /// Normal constructor for testing.
  Library(Map yaml) : super(yaml['qualifiedName'], yaml['name']) {
    loadValues(yaml);
    buildHierarchy(this, this);
  } 
  
  void addToHierarchy() {
    pageIndex[qualifiedName] = this;
    [classes, typedefs, errors, functions].forEach((category) {
      category.content.forEach((clazz) {
        buildHierarchy(clazz, this);
      });
    });
  }
  
  void loadValues(Map yaml) {
    this.comment = _wrapComment(yaml['comment']);
    var classes, exceptions, typedefs;
    var allClasses = yaml['classes'];
    if (allClasses != null) {
      classes = allClasses['class'];
      exceptions = allClasses['error'];
      typedefs = allClasses['typedef'];
    }
    this.typedefs = new Category.forTypedefs(typedefs);
    errors = new Category.forClasses(exceptions, 'Exceptions');
    this.classes = new Category.forClasses(classes, 'Classes');
    var setters, getters, methods, operators;
    var allFunctions = yaml['functions'];
    if (allFunctions != null) {
      setters = allFunctions['setters'];
      getters = allFunctions['getters'];
      methods = allFunctions['methods'];
      operators = allFunctions['operators'];
    }
    variables = new Category.forVariables(yaml['variables'], getters, setters);
    functions = new Category.forFunctions(methods, 'Functions');
    this.operators = new Category.forFunctions(operators, 'Operators', 
        isOperator: true);
    _sort([this.classes.content, this.errors.content, 
           this.typedefs.content, this.variables.content,
           this.functions.content, this.operators.content]);
    isLoaded = true;
  }
}

/**
 * An [Item] that describes a single Dart class.
 */
class Class extends LazyItem {
  
  Category functions;
  Category variables;
  Category constructs;
  Category operators;
  LinkableType superClass;
  bool isAbstract;
  String previewComment;
  List<Annotation> annotations;
  List<LinkableType> implements;
  List<LinkableType> subclasses;
  List<String> generics = [];

  /// Creates a [Class] placeholder object with null fields.
  Class.forPlaceholder(String location, this.previewComment) 
      : super(location, location.split('.').last);
  
  /// Normal constructor for testing.
  Class(Map yaml) : super(yaml['qualifiedName'], yaml['name']) {
    loadValues(yaml);
  }
  
  void addToHierarchy() {
    pageIndex[qualifiedName] = this;
    if (isLoaded) {
      [functions, constructs, operators].forEach((category) {
        category.content.forEach((clazz) {
          buildHierarchy(clazz, this);
        });
      });
    }
  }
  
  void loadValues(Map yaml) {
    comment = _wrapComment(yaml['comment']);
    isAbstract = yaml['isAbstract'] == 'true';
    superClass = new LinkableType(yaml['superclass']);
    subclasses = yaml['subclass'] == null ? [] :
      yaml['subclass'].map((item) => new LinkableType(item)).toList();
    annotations = yaml['annotations'] == null ? [] :
        yaml['annotations'].map((item) => new Annotation(item)).toList();
    implements = yaml['implements'] == null ? [] :
        yaml['implements'].map((item) => new LinkableType(item)).toList();
    var genericValues = yaml['generics'];
    if (genericValues != null) {
      genericValues.keys.forEach((generic) => generics.add(generic));
    }
    var setters, getters, methods, operates, constructors;
    var allMethods = yaml['methods'];
    if (allMethods != null) {
      setters = allMethods['setters'];
      getters = allMethods['getters'];
      methods = allMethods['methods'];
      operates = allMethods['operators'];
      constructors = allMethods['constructors'];
    }
    variables = new Category.forVariables(yaml['variables'], getters, setters);
    functions = new Category.forFunctions(methods, 'Functions');
    operators = new Category.forFunctions(operates, 'Operators',
        isOperator: true);
    constructs = new Category.forFunctions(constructors, 'Constructors', 
        isConstructor: true, className: this.name);
    var inheritedMethods = yaml['inheritedMethods'];
    var inheritedVariables = yaml['inheritedVariables'];
    if (inheritedMethods != null) {
      setters = inheritedMethods['setters'];
      getters = inheritedMethods['getters'];
      methods = inheritedMethods['methods'];
      operates = inheritedMethods['operators'];
    }
    _addVariable(inheritedVariables);
    _addVariable(setters, isSetter: true);
    _addVariable(getters, isGetter: true);
    _addMethod(methods);
    _addMethod(operates, isOperator: true);
    _sort([this.functions.content, this.variables.content, 
           this.constructs.content, this.operators.content]);
    isLoaded = true;
  }
  
  /// Adds an inherited variable to [variables] if not present.
  void _addVariable(Map items, {isSetter: false, isGetter: false}) {
    if (items != null) {
      items.values.forEach((item) {
        var object = new Variable(item, isSetter: isSetter, 
            isGetter: isGetter, inheritedFrom: item['qualifiedName'],
            commentFrom: item['commentFrom']);
        variables.addInheritedItem(this, object);
      }); 
    }
  }
  
  /// Adds an inherited method to the correct [Category] if not present.
  void _addMethod(Map items, {isOperator: false}) {
    if (items != null) {
      items.values.forEach((item) {
        var object = new Method(item, isOperator: isOperator,
            inheritedFrom: item['qualifiedName'],
            commentFrom: item['commentFrom']);
        var location = isOperator ? this.operators : this.functions;
        location.addInheritedItem(this, object);
      });
    }
  }
}

/**
 * A single annotation to an [Item].
 */
class Annotation {
  
  String qualifiedName;
  LinkableType link;
  List<String> parameters;
  
  Annotation(Map yaml) {
    qualifiedName = yaml['name'];
    link = new LinkableType(qualifiedName);
    parameters = yaml['parameters'] == null ? [] : yaml['parameters'];
  }
}

/**
 * An [Item] that describes a Dart member with parameters.
 */
class Parameterized extends Item {
  
  List<Parameter> parameters;
  
  Parameterized(String name, String qualifiedName, [String comment]) 
      : super(name, qualifiedName, comment);
  
  /// Creates [Parameter] objects for each parameter to this method.
  List<Parameter> getParameters(Map parameters) {
    var values = [];
    if (parameters != null) {
      parameters.forEach((name, data) {
        values.add(new Parameter(name, data));
      });
    }
    return values;
  }
}

/**
 * An [Item] that describes a single Dart typedef.
 */
class Typedef extends Parameterized {
  
  LinkableType type;
  List<Annotation> annotations;
  
  Typedef(Map yaml) : super(yaml['name'], yaml['qualifiedName'],
      _wrapComment(yaml['comment'])) {
    type = new LinkableType(yaml['return']);
    parameters = getParameters(yaml['parameters']);
    annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new Annotation(item)).toList();
  }
}

/**
 * An [Item] that describes a single Dart method.
 */
class Method extends Parameterized {

  bool isStatic;
  bool isAbstract;
  bool isConstant;
  bool isConstructor;
  String inheritedFrom;
  String commentFrom;
  String className;
  bool isOperator;
  List<LinkableType> annotations;
  NestedType type;

  Method(Map yaml, {bool isConstructor: false, String className: '', 
      bool isOperator: false, String inheritedFrom: '',
      String commentFrom: ''}) 
        : super(yaml['name'], yaml['qualifiedName'], 
            _wrapComment(yaml['comment'])) {
    this.isStatic = yaml['static'] == 'true';
    this.isAbstract = yaml['abstract'] == 'true';
    this.isConstant = yaml['constant'] == 'true';
    this.isOperator = isOperator;
    this.isConstructor = isConstructor;
    this.inheritedFrom = inheritedFrom;
    this.commentFrom = commentFrom == '' ? yaml['commentFrom'] : commentFrom;
    this.type = new NestedType(yaml['return'].first);
    parameters = getParameters(yaml['parameters']);
    this.className = className;
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new Annotation(item)).toList();
  }

  void addToHierarchy() {
    if (inheritedFrom != '') pageIndex[qualifiedName] = this;
  }
  
  void addInheritedComment(Item item) {
    if (comment == '<span></span>') {
      comment = item.comment;
      commentFrom = item.commentFrom;
    }
  }
  
  bool get isInherited => inheritedFrom != '' && inheritedFrom != null;
  
  String get decoratedName => isConstructor ? 
      (name != '' ? '$className.$name' : className) : name;
}

/**
 * A single parameter to a [Method].
 */
class Parameter {
  
  String name;
  bool isOptional;
  bool isNamed;
  bool hasDefault;
  NestedType type;
  String defaultValue;
  List<Annotation> annotations;
  
  Parameter(this.name, Map yaml) {
    this.isOptional = yaml['optional'] == 'true';
    this.isNamed = yaml['named'] == 'true';
    this.hasDefault = yaml['default'] == 'true';
    this.type = new NestedType(yaml['type'].first);
    this.defaultValue = yaml['value'];
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new Annotation(item)).toList();
  }
  
  String get decoratedName {
    var decorated = name;
    if (hasDefault) {
      if (isNamed) {
        decorated = '$decorated: $defaultValue';
      } else {
        decorated = '$decorated=$defaultValue';
      }
    }
    return decorated;
  }
}

/**
 * A [Container] that describes a single Dart variable.
 */
class Variable extends Item {
  
  bool isFinal;
  bool isStatic;
  bool isAbstract;
  bool isConstant;
  bool isGetter;
  bool isSetter;
  String inheritedFrom;
  String commentFrom;
  Parameter setterParameter;
  NestedType type;
  List<Annotation> annotations;

  Variable(Map yaml, {bool isGetter: false, bool isSetter: false,
      String inheritedFrom: '', String commentFrom: ''})
      : super(yaml['name'], yaml['qualifiedName'], 
          _wrapComment(yaml['comment'])) {
    this.isGetter = isGetter;
    this.isSetter = isSetter;
    this.inheritedFrom = inheritedFrom;
    this.commentFrom = commentFrom == '' ? yaml['commentFrom'] : commentFrom;
    isFinal = yaml['final'] == 'true';
    isStatic = yaml['static'] == 'true';
    isConstant = yaml['constant'] == 'true';
    isAbstract = yaml['abstract'] == 'true';
    if (isGetter) {
      type = new NestedType(yaml['return'].first);
    } else if (isSetter) {
      type = new NestedType(yaml['return'].first);
      var parameters = yaml['parameters'];
      var parameterName = parameters.keys.first;
      setterParameter = new Parameter(parameterName, 
          parameters[parameterName]);
    } else {
      type = new NestedType(yaml['type'].first);
    }
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new Annotation(item)).toList();
  }
  
  void addInheritedComment(Item item) {
    if (comment == '<span></span>') {
      comment = item.comment;
      commentFrom = item.commentFrom;
    }
  }
  
  bool get isInherited => inheritedFrom != '' && inheritedFrom != null;
  
  void addToHierarchy() {
    if (inheritedFrom != '') pageIndex[qualifiedName] = this;
  }
}

/**
 * A Dart type that potentially contains generic parameters.
 */
class NestedType {
  LinkableType outer;
  List<NestedType> inner = [];
  
  NestedType(Map yaml) {
    if (yaml == null) {
      outer = new LinkableType('void');
    } else {
      outer = new LinkableType(yaml['outer']);
      var innerMap = yaml['inner'];
      if (innerMap != null)
      innerMap.forEach((element) => inner.add(new NestedType(element)));
    }
  }
}

/**
 * A Dart type that should link to other [Item]s.
 */
class LinkableType {

  /// The resolved qualified name of the type this [LinkableType] represents.
  String type;
  
  /// The constructor resolves the library name by finding the correct library
  /// from [libraryNames] and changing [type] to match.
  LinkableType(String type) {
    var current = type;
    this.type = findLibraryName(type);
  }

  /// The simple name for this type.
  String get simpleType => type.split('.').last;

  /// The [Item] describing this type if it has been loaded, otherwise null.
  String get location => type;
}