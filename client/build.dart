#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';
import 'dart:async';

void main() {
  build(entryPoints: ['web/index.html'])
    .then((_) => print('Build finished!'));
}
