import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import '../entities/playground_value.dart';

///
class PlaygroundBuilder extends StatelessWidget {
  ///
  const PlaygroundBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  ///
  final Widget Function(
      BuildContext context, PlaygroundValue value, Widget? child) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaygroundValue>(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }
}
