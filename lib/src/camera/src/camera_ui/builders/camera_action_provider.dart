import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../controllers/camera_action.dart';

///
class CameraActionProvider extends InheritedWidget {
  /// Creates a widget that associates a [CameraAction] with a subtree.
  const CameraActionProvider({
    Key? key,
    required CameraAction this.action,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [CameraAction].
  const CameraActionProvider.none({
    Key? key,
    required Widget child,
  })  : action = null,
        super(key: key, child: child);

  /// The [CameraAction] associated with the subtree.
  ///
  final CameraAction? action;

  /// Returns the [CameraAction] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [CameraAction] associated with the
  /// given context.
  static CameraAction? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<CameraActionProvider>();
    return result?.action;
  }

  @override
  bool updateShouldNotify(covariant CameraActionProvider oldWidget) =>
      action != oldWidget.action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CameraAction>(
      'controller',
      action,
      ifNull: 'no controller',
      showName: false,
    ));
  }
}

///
extension CameraActionProviderExtension on BuildContext {
  /// [CameraAction] instance
  CameraAction? get action => CameraActionProvider.of(this);
}
