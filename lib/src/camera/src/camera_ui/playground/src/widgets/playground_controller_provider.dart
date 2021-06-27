import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';

///
class PlaygroundControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [PlaygroundController] with a subtree.
  const PlaygroundControllerProvider({
    Key? key,
    required PlaygroundController this.action,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [PlaygroundController].
  const PlaygroundControllerProvider.none({
    Key? key,
    required Widget child,
  })  : action = null,
        super(key: key, child: child);

  /// The [PlaygroundController] associated with the subtree.
  ///
  final PlaygroundController? action;

  /// Returns the [PlaygroundController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [PlaygroundController] associated with the
  /// given context.
  static PlaygroundController? of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<PlaygroundControllerProvider>();
    return result?.action;
  }

  @override
  bool updateShouldNotify(covariant PlaygroundControllerProvider oldWidget) =>
      action != oldWidget.action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PlaygroundController>(
      'controller',
      action,
      ifNull: 'no controller',
      showName: false,
    ));
  }
}

///
extension PlaygroundControllerProviderExtension on BuildContext {
  /// [PlaygroundController] instance
  PlaygroundController? get playgroundController =>
      PlaygroundControllerProvider.of(this);
}
