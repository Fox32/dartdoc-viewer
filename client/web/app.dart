// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * This application displays documentation generated by the docgen tool
 * found at dart-repo/dart/pkg/docgen.
 *
 * The Yaml file outputted by the docgen tool will be read in to
 * generate [Page] and [Category] and [CompositeContainer].
 * Pages, Categories and CategoryItems are used to format and layout the page.
 */
// TODO(janicejl): Add a link to the dart docgen landing page in future.
library web.app;

import 'dart:async';
import 'dart:html' show Element, querySelector, window, ScrollAlignment,
    Event, AnchorElement;
import 'dart:convert';

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:dartdoc_viewer/location.dart';
import 'package:polymer/polymer.dart';
import 'package:template_binding/template_binding.dart';
import 'main.dart';

// TODO(janicejl): JSON path should not be hardcoded.
// Path to the JSON file being read in. This file will always be in JSON
// format and contains the format of the rest of the files.
String sourcePath = 'docs/library_list.json';

/// This is the cut off point between mobile and desktop in pixels.
// TODO(janicejl): Use pixel desity rather than how many pixels. Look at:
// http://www.mobilexweb.com/blog/ipad-mini-detection-for-html5-user-agent
const int desktopSizeBoundary = 1006;

/// The [Viewer] object being displayed.
final Viewer viewer = new Viewer._();

MainElement dartdocMain = querySelector("#dartdoc-main");

/// The Dartdoc Viewer application state.
class Viewer extends Observable {

  @observable bool isDesktop;

  Future finished;

  /// The homepage from which every [Item] can be reached.
  @observable Home homePage;

  bool _showPkgLibraries = false;
  @observable bool get showPkgLibraries => _showPkgLibraries;
  @observable set showPkgLibraries(bool newValue) {
    if (_showPkgLibraries == newValue) return;

    _showPkgLibraries = notifyPropertyChange(#showPkgLibraries,
        _showPkgLibraries, newValue);

    _updateLibraries();
  }

  @observable List libraries;

  _updateLibraries() {
    if (currentPage == null) {
      libraries = [];
    } else {
      libraries = currentPage.home.libraries;
      if (!showPkgLibraries) {
        libraries = libraries.where((x) => x is Library).toList();
      }
    }
  }

  // TODO(alanknight): Restore the type declaration here and structure the code
  // so we can avoid the warnings from casting to subclasses.
  Item _currentPage;

  /// The current page being shown. An Item.
  @observable Item get currentPage => _currentPage;
  @observable set currentPage(Item newPage) {
    if (_currentPage == newPage) return;

    _currentPage = notifyPropertyChange(#currentPage, _currentPage, newPage);
    _updateLibraries();
  }

  /// State for whether or not the library list panel should be shown.
  @observable bool isPanel = true;
  bool _isPanel = true;

  /// State for whether or not the minimap panel should be shown.
  @observable bool isMinimap = true;
  bool _isMinimap = true;

  /// State for whether or not inherited members should be shown.
  @observable bool isInherited = false;

  /// The current element on the current page being shown (e.g. #dartdoc-top).
  String _hash;

  // Private constructor for singleton instantiation.
  Viewer._() {
    var manifest = retrieveFileContents(sourcePath);
    finished = manifest.then((response) {
      var libraries = JSON.decode(response);
      isYaml = libraries['filetype'] == 'yaml';
      homePage = new Home(libraries);
    });

    _updateDesktopMode(null);
    window.onResize.listen(_updateDesktopMode);
  }

  _updateDesktopMode(_) {
    isDesktop = window.innerWidth > desktopSizeBoundary;
    isMinimap = isDesktop && _isMinimap;
    isPanel = isDesktop && _isPanel;
  }

  /// The title of the current page.
  String get title => currentPage == null ? '' : currentPage.decoratedName;

  /// Scrolls the screen to the correct member if necessary.
  void _scrollScreen(String hash) {
    if (hash == null || hash == '') {
      Timer.run(() {
        window.scrollTo(0, 0);
      });
    } else {
      Timer.run(() {
        // All ids are created using getIdName to avoid creating an invalid
        // HTML id from an operator or setter.
        hash = hash.substring(1, hash.length);
        var e = queryEverywhere(dartdocMain, hash);

        if (e != null) {
          e.scrollIntoView();
          // The navigation bar at the top of the page is 60px wide,
          // so scroll down 60px once the browser scrolls to the member.
          window.scrollBy(0, -80);
          // TODO(alanknight): The focus only shows up the element if it's
          // a link, e.g. classes. It would be nice to highlight sub-members
          e.focus();
        }
      });
    }
  }

  /// Query for an element by [id] in [parent] and in all the shadow
  /// roots. If it's not found, return [null].
  Element queryEverywhere(Element parent, String id) {
    if (parent.id == id) return parent;
    var shadowChildren =
        parent.shadowRoot != null ? parent.shadowRoot.children : const [];
    var allChildren = [parent.children, shadowChildren]
        .expand((x) => x);
    for (var e in allChildren) {
      var found = queryEverywhere(e, id);
      if (found != null) return found;
    }
    return null;
  }

  /// Updates [currentPage] to be [page].
  Future _updatePage(Item page, DocsLocation location) {
    if (page != null) {
      // Since currentPage is observable, if it changes the page reloads.
      // This avoids reloading the page when it isn't necessary.
      if (page != currentPage) currentPage = page;
      _hash = location.anchorPlus;
      _scrollScreen(location.anchorPlus);
    }
    return new Future.value(true);
  }

  /// Loads the [libraryName] [Library] and [className] [Class] if necessary
  /// and updates the current page to the member described by [location]
  /// once the correct member is found and loaded.
  Future _loadAndUpdatePage(DocsLocation location) {
    // If it's loaded, it will be in the index.
    var destination = pageIndex[location.withoutAnchor];
    if (destination == null) {
      // TODO(alanknight) : A cleaner way to do this.
      // Transform references to sub-members into anchors
      if (location.subMemberName != null) {
        var newLocation = new DocsLocation(location.parentQualifiedName);
        newLocation.anchor = newLocation.toHash(location.subMemberName);
        var newUri = newLocation.withAnchor;
        var encoded = Uri.encodeFull(newUri);
        window.history.pushState("#$encoded", viewer.title, "#$encoded");
        return handleLink(encoded);
      }
      return getItem(location).then((items)
          => _updatePage(location.itemFromList(items.toList()), location));
    } else {
      return destination.load().then((_) => _updatePage(destination, location));
    }
  }

  /// Find the item corresponding to this location
  Future getItem(DocsLocation location) =>
    getLibrary(location)
      .then((lib) => getMember(lib, location))
      .then((libWithMember) => getSubMember(libWithMember, location));

  // All libraries should be in [pageIndex], but may not be loaded.
  // TODO(alanknight): It would be nice if this could all be methods on
  // Location, but it doesn't have access to the lookup context right now.
  /// Return a future for the given item, ensuring that it and all its
  /// parent items are loaded.
  Future<Item> getLibrary(DocsLocation location) {
    var lib = pageIndex[location.libraryQualifiedName];
    // If we can't find the name in the pageIndex, look through the home
    // to see if we can find it there, searching by displayed name. Mostly
    // important to find things like dart:html, which is really dart-dom-html
    if (lib == null) {
      lib = viewer.homePage.memberNamed(location.libraryName);
    }
    if (lib == null) return new Future.value(null);
    return lib.load();
  }

  Future<List<Item>> getMember(lib, DocsLocation location) {
    if (lib == null) return new Future.value(null);
    var member = lib.memberNamed(location.memberName);
    if (member == null) return new Future.value([lib, null]);
    return member.load().then((mem) => new Future.value([lib, member]));
  }

  Future<List<Item>> getSubMember(List libWithMember, DocsLocation location) {
    if (libWithMember == null) return new Future.value([]);
    if (libWithMember.last == null) {
      return new Future.value([libWithMember.first]);
    }
    return new Future.value(concat(libWithMember,
      [libWithMember.last.memberNamed(location.subMemberName)]));
  }

  /// Looks for the correct [Item] described by [location]. If it is found,
  /// [currentPage] is updated and state is not pushed to the history api.
  /// Returns a [Future] to determine if a link was found or not.
  /// [location] is a [String] path to the location (either a qualified name
  /// or a url path).
  Future handleLink(String uri) {
    // Links are the hash part of the URI without the leading #.
    // Valid forms for links are
    // home - the global home page
    // library.memberName.subMember#anchor
    // where #anchor is optional and library can be any of
    // dart:library, library-foo, package-foo/library-bar
    // So we need an unambiguous form.
    // [package/]libraryWithDashes[.class.method]#anchor

    // We will tolerate colons in the location instead of dashes, though
    var decoded = Uri.decodeFull(uri);
    var location = new DocsLocation(decoded);

    if (location.libraryName == 'home') {
      _updatePage(viewer.homePage, location);
      return new Future.value(true);
    }
    return _loadAndUpdatePage(location);
    // TODO(alanknight) : This is now letting the history automatically
    // update, even for non-found items. Is that an issue?
  }

  /// Toggles the library panel
  void togglePanel() {
    _isPanel = !_isPanel;
    isPanel = isDesktop && _isPanel;
  }

  /// Toggles the minimap panel
  void toggleMinimap() {
    _isMinimap = !_isMinimap;
    isMinimap = isDesktop && _isMinimap;
  }

  void togglePkg() {
    showPkgLibraries = !showPkgLibraries;
  }

  /// Toggles showing inherited members.
  void toggleInherited() {
    isInherited = !isInherited;
  }
}

/// The path of this app on startup.
String _pathname;

/// The latest url reached by a popState event.
String location;

/// Listens for browser navigation and acts accordingly.
void startHistory() {
  location = window.location.hash.replaceFirst('#', '');
  // TODO(alanknight): onPopState doesn't work in IE, so using onHashChange.
  // window.onPopState.listen(navigate);
  window.onHashChange.listen(navigate);
}

void navigate(event) {
  // TODO(alanknight): Should we be URI encoding/decoding this?
  var newLocation = window.location.hash.replaceFirst('#', '');
  if (viewer.homePage != null) {
    viewer.handleLink(newLocation);
  }
}

/// Handles browser navigation.
@initMethod _init() {
  window.onResize.listen((event) {
    viewer.isDesktop = window.innerWidth > desktopSizeBoundary;
  });

  startHistory();
  // If a user navigates to a page other than the homepage, the viewer
  // must first load fully before navigating to the specified page.
  viewer.finished.then((_) {
    if (location != null && location != '') {
      viewer.handleLink(location);
    } else {
      viewer.currentPage = viewer.homePage;
    }
    retrieveFileContents('docs/index.json').then((String json) {
      index.map = JSON.decode(json);
    });
  });
}

Iterable concat(Iterable list1, Iterable list2) =>
    [list1, list2].expand((x) => x);

main() => initPolymer();


final defaultSyntax = new _DefaultSyntaxWithEvents();

// TODO(jmesserly): for now we disable polymer expressions
class _DefaultSyntaxWithEvents extends BindingDelegate {
  prepareBinding(String path, name, node) =>
      Polymer.prepareBinding(path, name, node, super.prepareBinding);
}
