import 'package:flutter/material.dart';

import '../../controllers/camera_action.dart';
import 'camera_action_provider.dart';

///
class ActionDetector extends StatelessWidget {
  ///
  const ActionDetector({
    Key? key,
    this.onPressed,
    this.builder,
    this.child,
  }) : super(key: key);

  ///
  final void Function(CameraAction action)? onPressed;

  ///
  final Widget Function(CameraAction action, BoxConstraints constraints)?
      builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final action = context.action;
        final widget = action == null
            ? child
            : builder?.call(action, constraints) ?? child;

        if (onPressed == null) {
          return widget ?? const SizedBox();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (action == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera not found!')),
              );
            } else {
              onPressed?.call(action);
            }
          },
          child: widget,
        );
      },
    );
  }
}

///
class ActionBuilder extends StatelessWidget {
  ///
  const ActionBuilder({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final Widget Function(CameraAction action, ActionValue value, Widget? child)
      builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ActionDetector(
      builder: (action, constraints) {
        return ValueListenableBuilder<ActionValue>(
          valueListenable: action,
          builder: (context, value, child) {
            return builder(action, value, child);
          },
          child: child,
        );
      },
    );
  }
}
