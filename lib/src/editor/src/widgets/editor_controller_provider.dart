import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
class PhotoEditingControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [DrishyaEditingController] with a
  /// subtree.
  const PhotoEditingControllerProvider({
    Key? key,
    required DrishyaEditingController this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [DrishyaEditingController].
  const PhotoEditingControllerProvider.none({
    Key? key,
    required Widget child,
  })  : controller = null,
        super(key: key, child: child);

  /// The [DrishyaEditingController] associated with the subtree.
  ///
  final DrishyaEditingController? controller;

  /// Returns the [DrishyaEditingController] most closely associated
  /// with the given context.
  ///
  /// Returns null if there is no [DrishyaEditingController] associated with the
  /// given context.
  static DrishyaEditingController? of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<PhotoEditingControllerProvider>();
    return result?.controller;
  }

  @override
  bool updateShouldNotify(covariant PhotoEditingControllerProvider oldWidget) =>
      controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<DrishyaEditingController>(
        'controller',
        controller,
        ifNull: 'no controller',
        showName: false,
      ),
    );
  }
}

///
extension PlaygroundControllerProviderExtension on BuildContext {
  /// [DrishyaEditingController] instance
  DrishyaEditingController? get photoEditingController =>
      PhotoEditingControllerProvider.of(this);
}
