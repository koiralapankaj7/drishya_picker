import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class EditorBuilder extends StatelessWidget {
  ///
  const EditorBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final PhotoEditingController controller;

  ///
  final Widget Function(
    BuildContext context,
    PhotoValue value,
    Widget? child,
  ) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PhotoValue>(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }
}
