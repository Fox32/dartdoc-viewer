#!/usr/bin/env dart

import 'package:polymer/component_build.dart';
import 'dart:io';
import 'dart:async';

void main() {
  var args = new List.from(new Options().arguments);
  build(args, ['web/index.html'])
    .then((_) => print('Build finished!'));
}
