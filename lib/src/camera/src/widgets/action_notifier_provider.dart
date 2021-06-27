import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/action_notifier.dart';

///
class ActionNotifierProvider extends InheritedWidget {
  /// Creates a widget that associates a [ActionNotifier] with a subtree.
  const ActionNotifierProvider({
    Key? key,
    required ActionNotifier this.action,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [ActionNotifier].
  const ActionNotifierProvider.none({
    Key? key,
    required Widget child,
  })  : action = null,
        super(key: key, child: child);

  /// The [ActionNotifier] associated with the subtree.
  ///
  final ActionNotifier? action;

  /// Returns the [ActionNotifier] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [ActionNotifier] associated with the
  /// given context.
  static ActionNotifier? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ActionNotifierProvider>();
    return result?.action;
  }

  @override
  bool updateShouldNotify(covariant ActionNotifierProvider oldWidget) =>
      action != oldWidget.action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ActionNotifier>(
      'controller',
      action,
      ifNull: 'no controller',
      showName: false,
    ));
  }
}

///
extension ActionNotifierProviderExtension on BuildContext {
  /// [ActionNotifier] instance
  ActionNotifier? get action => ActionNotifierProvider.of(this);
}
