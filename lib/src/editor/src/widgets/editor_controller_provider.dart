import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
class PhotoEditingControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [PhotoEditingController] with a
  /// subtree.
  const PhotoEditingControllerProvider({
    Key? key,
    required PhotoEditingController this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [PhotoEditingController].
  const PhotoEditingControllerProvider.none({
    Key? key,
    required Widget child,
  })  : controller = null,
        super(key: key, child: child);

  /// The [PhotoEditingController] associated with the subtree.
  ///
  final PhotoEditingController? controller;

  /// Returns the [PhotoEditingController] most closely associated
  /// with the given context.
  ///
  /// Returns null if there is no [PhotoEditingController] associated with the
  /// given context.
  static PhotoEditingController? of(BuildContext context) {
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
      DiagnosticsProperty<PhotoEditingController>(
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
  /// [PhotoEditingController] instance
  PhotoEditingController? get photoEditingController =>
      PhotoEditingControllerProvider.of(this);
}
