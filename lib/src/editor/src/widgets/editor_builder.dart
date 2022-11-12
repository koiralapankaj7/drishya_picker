import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class EditorBuilder extends StatelessWidget {
  ///
  const EditorBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.child,
  });

  ///
  final DrishyaEditingController controller;

  ///
  final Widget Function(
    BuildContext context,
    EditorValue value,
    Widget? child,
  ) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EditorValue>(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }
}
