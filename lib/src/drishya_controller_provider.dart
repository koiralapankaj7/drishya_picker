import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gallery/gallery_view.dart';

///
class DrishyaControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [DrishyaController] with a subtree.
  const DrishyaControllerProvider({
    Key? key,
    required DrishyaController this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [DrishyaController].
  const DrishyaControllerProvider.none({
    Key? key,
    required Widget child,
  })  : controller = null,
        super(key: key, child: child);

  /// The [DrishyaController] associated with the subtree.
  ///
  final DrishyaController? controller;

  /// Returns the [DrishyaController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [DrishyaController] associated with the
  /// given context.
  static DrishyaController? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<DrishyaControllerProvider>();
    return result?.controller;
  }

  @override
  bool updateShouldNotify(covariant DrishyaControllerProvider oldWidget) =>
      controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DrishyaController>(
      'controller',
      controller,
      ifNull: 'no controller',
      showName: false,
    ));
  }
}

///
extension DrishyaControllerProviderExtension on BuildContext {
  /// [DrishyaController] instance
  DrishyaController? get drishyaController =>
      DrishyaControllerProvider.of(this);
}
