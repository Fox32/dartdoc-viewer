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
class Search extends PolymerElement {

  Search() {
    new PathObserver(this, "results").bindSync(
        (_) {
          notifyProperty(this, #dropdownOpen);
          notifyProperty(this, #hasNoResults);
        });
    new PathObserver(this, "isFocused").bindSync(
        (_) {
          notifyProperty(this, #dropdownOpen);
        });
  }

  List<SearchResult> results = [];

  @observable bool isFocused = false;

  @observable String searchQuery = "";

  @observable bool get hasNoResults => results.isNotEmpty;

  @observable String get dropdownOpen =>
      !searchQuery.isEmpty && isFocused ? 'open' : '';

  int currentIndex = -1;

  void updateResults(event, detail, target) {
    currentIndex = -1;
    results.clear();
    results.addAll(lookupSearchResults(searchQuery, viewer.isDesktop ? 10 : 5));
    notifyProperty(this, #results);
    notifyProperty(this, #dropdownOpen);
  }

  void onBlurCallback(_) {
    // TODO(alanknight): The below check fails with shadow root because the
    // active element
    // is always the main one. Is it ok to just not do this test and lose
    // focus any time we get a blur callback?
//    if (document.activeElement == null ||
//        !this.contains(document.activeElement)) {
      isFocused = false;
//    }
  }

  void onFocusCallback(_) {
    isFocused = true;
  }

  void onSubmitCallback(event, detail, target) {
    if (!results.isEmpty) {
      String refId;
      if (target != null ) {
        // We get either the li or a element depending if we click or
        // hit enter, so check both.
        refId = target.dataset['ref-id'];
        var parentRefId = target.parent.dataset['ref-id'];
        if (refId == null) refId = parentRefId;
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
      isFocused = false;
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
        shadowRoot.query('#search$currentIndex').focus();
      } else if (currentIndex == 0) {
        q.focus();
      }
      e.preventDefault();
    } else if (e.keyCode == KeyCode.DOWN) {
      if (currentIndex < results.length - 1) {
        print(currentIndex);
        currentIndex++;
        shadowRoot.query('#search$currentIndex').parent.focus();
      }
      e.preventDefault();
    } else {
      updateResults(e, null, null);
    }
  }

  /** Activate search on Ctrl+3 and S. */
  void shortcutHandler(KeyboardEvent event) {
    if (event.keyCode == KeyCode.THREE && event.ctrlKey) {
      q.focus();
      event.preventDefault();
    } else if (event.target != q && event.keyCode == KeyCode.S) {
      // Allow writing 's' in the search input.
      q.focus();
      event.preventDefault();
    } else if (event.keyCode == KeyCode.ESC) {
      document.body.focus();
      isFocused = false;
      event.preventDefault();
    }
  }

  get q => shadowRoot.query('#q');

  get applyAuthorStyles => true;
}