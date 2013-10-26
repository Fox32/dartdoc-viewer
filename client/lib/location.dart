// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library location;

// TODO(alanknight): You need to get the set of allowed characters for these
// correct, which it definitely is not right now.
final packageMatch = new RegExp(r'(\w+)/');
final libraryMatch = new RegExp(r'([\w\-\:\_]+)');
final memberMatch = new RegExp(r'\.([\w\_]+)');
// TODO(alanknight): This should exclude a trailing slash along with any
// disallowed characters in the anchor.
final anchorMatch = new RegExp(r'\#(.+)');

// This represents a component described by a URI and can give us
// the URI given the component or vice versa.
class Location {
  String packageName;
  String libraryName;
  String memberName;
  String subMemberName;
  String anchor;

  Location.empty();

  Location(String uri) {
    _extractPieces(uri);
  }

  Location.fromList(List<String> components) {
    if (components.length > 0) packageName = components[0];
    if (components.length > 1) libraryName = components[1];
    if (components.length > 2) memberName = components[2];
    if (components.length > 3) subMemberName = components[3];
    if (components.length > 4) anchor = components[4];
  }

  void _extractPieces(String uri) {
    var position = 0;

    _check(regex) {
      var match = regex.matchAsPrefix(uri, position);
      if (match != null) {
        var matchedString = match.group(1);
        position = position + match.group(0).length;
        return matchedString;
      }
    }

    packageName = _check(packageMatch);
    libraryName = _check(libraryMatch);
    memberName = _check(memberMatch);
    subMemberName = _check(memberMatch);
    anchor = _check(anchorMatch);
  }

  String get withoutAnchor =>
      [packagePlus, libraryPlus, memberPlus, subMemberPlus].join("");

  String get libraryQualifiedName => "$packagePlus$libraryPlus";

  String get withAnchor => withoutAnchor + anchorPlus;

  get packagePlus => packageName == null
      ? ''
      : libraryName == null
          ? packageName
          : '$packageName/';
  get memberPlus => memberName == null ? '' : '.$memberName';
  get subMemberPlus => subMemberName == null ? '' : '.$subMemberName';
  get libraryPlus => libraryName == null ? '' :  libraryName;
  get anchorPlus => anchor == null ? '' : '#$anchor';

  /// Return a list of the components' basic names. Omits the anchor, but
  /// includes the package name, even if it is null.
  List<String> get componentNames =>
      [packageName]..addAll(
          [libraryName, memberName, subMemberName].where((x) => x != null));

  List items(root) {
    var items = [];
    var package = packageName == null
        ? null
        : root.memberNamed(packageName);
    if (package != null) items.add(package);
    if (libraryName == null) return items;
    var library = items.last.memberNamed(libraryName);
    items.add(library);
    var member = memberName == null
        ? library.memberNamed(memberName) : null;
    if (member != null) {
      items.add(member);
      var subMember = subMemberName == null
          ? member.memberNamed(subMemberName)  : null;
      if (subMember != null) items.add(subMember);
    }
    return items;
  }

  /// Return the item in the list that corresponds to the thing we represent.
  /// Assumes that the items all match what we describe, so really amounts
  /// to finding the last non-nil entry.
  itemFromList(List items) => items.reversed.firstWhere((x) => x != null);

  /// Creates a valid hash ID for anchor tags.
  String toHash(String hash) {
    return 'id_' + hash;
  }

  get parentQualifiedName {
    return new Location.fromList(componentNames..removeLast()).withoutAnchor;
  }

  toString() => 'Location($withAnchor)';
}
