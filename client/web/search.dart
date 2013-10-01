// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library search;

import 'dart:async';
import 'dart:html' hide Element;
import 'dart:html' as html show Element; // #### Why?
import 'app.dart';
import 'package:dartdoc_viewer/item.dart';
import '../lib/search.dart';
import 'package:polymer/polymer.dart';
import 'results.dart';

/**
 * Component implementing the Dartdoc_viewer search.
 */
@CustomTag("search-box")
class Search extends PolymerElement with ObservableMixin {

  Search() {
    new PathObserver(this, "results").bindSync(
        (_) {
          notifyProperty(this, #dropdownOpen);
        });
    new PathObserver(this, "isFocused").bindSync(
        (_) {
          notifyProperty(this, #dropdownOpen);
        });
  }


  ObservableList<SearchResult> results = toObservable(<SearchResult>[]);
  String _lastQuery;
  @observable bool isFocused = false;

  @observable String searchQuery = "";

  @observable String get dropdownOpen =>
      !searchQuery.isEmpty && isFocused ? 'open' : '';

  int currentIndex = -1;

  void updateResults(event, detail, target) {
    currentIndex = -1;
    results.clear();
    results.addAll(lookupSearchResults(searchQuery, viewer.isDesktop ? 10 : 5));
  }

  void onBlurCallback(_) {
    if (document.activeElement == null ||
        !this.contains(document.activeElement)) {
      isFocused = false;
    }
  }

  void onFocusCallback(_) {
    isFocused = true;
  }

  void onSubmitCallback(event, detail, target) {
    if (!results.isEmpty) {
      String refId;
      if (target != null ) {
        refId = target.parent.dataset['ref-id'];
      }
      if (refId == null || refId.isEmpty) {
        // If nothing is focused, use the first search result.
        refId = results.first.element;
      }
      viewer.handleLink(new LinkableType(refId).location);
      searchQuery = "";
      results.clear();
      dartdocMain.searchSubmitted();
      document.body.focus();
    }
  }

  void inserted() {
    super.inserted();
    html.Element.focusEvent.forTarget(xtag, useCapture: true)
        .listen(onFocusCallback);
    html.Element.blurEvent.forTarget(xtag, useCapture: true)
        .listen(onBlurCallback);
    onKeyPress.listen(onKeyPressCallback);
    onKeyDown.listen(handleUpDown);
    window.onKeyDown.listen(shortcutHandler);
  }

  void onKeyPressCallback(KeyboardEvent e) {
    if (e.keyCode == KeyCode.ENTER) {
      onSubmitCallback(e, null, e.target);
      e.preventDefault();
    }
  }

  void handleUpDown(KeyboardEvent e) {
    if (e.keyCode == KeyCode.UP) {
      if (currentIndex > 0) {
        currentIndex--;
        document.query('#search$currentIndex').focus();
      } else if (currentIndex == 0) {
        document.query('#q').focus();
      }
      e.preventDefault();
    } else if (e.keyCode == KeyCode.DOWN) {
      if (currentIndex < results.length - 1) {
        currentIndex++;
        var x = document.query('#search*');
        document.query('#search$currentIndex').focus();
      }
      e.preventDefault();
    }
  }

  /** Activate search on Ctrl+3 and S. */
  void shortcutHandler(KeyboardEvent event) {
    if (event.keyCode == KeyCode.THREE && event.ctrlKey) {
      document.query('#q').focus();
      event.preventDefault();
    } else if (event.target != document.query('#q')
        && event.keyCode == KeyCode.S) {
      // Allow writing 's' in the search input.
      document.query('#q').focus();
      event.preventDefault();
    } else if (event.keyCode == KeyCode.ESC) {
      document.body.focus();
      isFocused = false;
      event.preventDefault();
    }
  }

  get applyAuthorStyles => true;
}