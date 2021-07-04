import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:drishya_picker/src/gallery/src/entities/gallery_value.dart';
import 'package:flutter/material.dart';

///
class GalleryBuilder extends StatelessWidget {
  ///
  const GalleryBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final Widget Function(GalleryValue value, Widget? child) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GalleryValue>(
      valueListenable: controller,
      builder: (ctx, v, c) => builder(v, c),
      child: child,
    );
  }
}
