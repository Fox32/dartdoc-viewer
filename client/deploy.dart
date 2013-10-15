#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';

void main() {
  lint()
    .then((_) => deploy()).then(compileToJs);
}

compileToJs(_) {
  print("Running dart2js");
  var dart2js = join(dirname(Platform.executable), 'dart2js');
  var result =
    Process.runSync(dart2js, ['--minify',
        '-o', 'out/web/index.html_bootstrap.dart.js',
	 'out/web/index.html_bootstrap.dart', 
      '--package-root=/Users/alanknight/dart-git/dart/xcodebuild/ReleaseIA32/packages'], runInShell: true);
  print(result.stdout);
  print("Done");
}
