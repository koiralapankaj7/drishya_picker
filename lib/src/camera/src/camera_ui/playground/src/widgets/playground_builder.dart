import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import '../entities/playground_value.dart';
import 'playground_controller_provider.dart';

///
class PlaygroundBuilder extends StatelessWidget {
  ///
  const PlaygroundBuilder({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final Widget Function(
          PlaygroundController action, PlaygroundValue value, Widget? child)
      builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return PlaygroundControllerDetector(
      builder: (controller, _) {
        return ValueListenableBuilder<PlaygroundValue>(
          valueListenable: controller,
          builder: (context, v, c) => builder(controller, v, c),
          child: child,
        );
      },
    );
  }
}

///
class PlaygroundControllerDetector extends StatelessWidget {
  ///
  const PlaygroundControllerDetector({
    Key? key,
    this.builder,
    this.child,
  }) : super(key: key);

  ///
  final Widget Function(
      PlaygroundController controller, BoxConstraints constraints)? builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controller = context.playgroundController;
        final view = child ?? const SizedBox();
        return controller == null
            ? view
            : builder?.call(controller, constraints) ?? view;
      },
    );
  }
}
