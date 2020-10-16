import 'dart:io';

import 'package:flutter/material.dart';

class PageWidget extends StatelessWidget {
  final Uri path;

  PageWidget(this.path);

  @override
  Widget build(BuildContext context) {
    var file = File.fromUri(path);
    var bytes = file.readAsBytesSync();
    Image image = Image.memory(bytes);
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Center(child: image),
    );
  }
}