import 'package:flutter/material.dart';

import '../controllers/action_notifier.dart';
import '../widgets/action_notifier_provider.dart';

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
  final void Function(ActionNotifier action)? onPressed;

  ///
  final Widget Function(ActionNotifier action, BoxConstraints constraints)?
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
  final Widget Function(ActionNotifier action, ActionValue value, Widget? child)
      builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ActionDetector(
      builder: (action, constraints) {
        return ValueListenableBuilder<ActionValue>(
          valueListenable: action,
          builder: (context, v, c) => builder(action, v, c),
          child: child,
        );
      },
    );
  }
}
