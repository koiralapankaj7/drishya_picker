// ignore_for_file: always_use_package_imports

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';

///
class CamControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [CamController] with a subtree.
  const CamControllerProvider({
    required CamController this.action, required Widget child, Key? key,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [CamController].
  const CamControllerProvider.none({
    required Widget child, Key? key,
  })  : action = null,
        super(key: key, child: child);

  /// The [CamController] associated with the subtree.
  ///
  final CamController? action;

  /// Returns the [CamController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [CamController] associated with the
  /// given context.
  static CamController? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<CamControllerProvider>();
    return result?.action;
  }

  @override
  bool updateShouldNotify(covariant CamControllerProvider oldWidget) =>
      action != oldWidget.action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<CamController>(
        'controller',
        action,
        ifNull: 'no controller',
        showName: false,
      ),
    );
  }
}

///
extension CamControllerProviderExtension on BuildContext {
  /// [CamController] instance
  CamController? get camController => CamControllerProvider.of(this);
}
