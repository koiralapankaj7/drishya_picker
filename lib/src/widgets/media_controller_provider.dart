import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../drishya_picker.dart';

///
class MediaControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [CustomMediaController] with a subtree.
  const MediaControllerProvider({
    Key? key,
    required CustomMediaController this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [CustomMediaController].
  const MediaControllerProvider.none({
    Key? key,
    required Widget child,
  })   : controller = null,
        super(key: key, child: child);

  /// The [CustomMediaController] associated with the subtree.
  ///
  final CustomMediaController? controller;

  /// Returns the [CustomMediaController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [CustomMediaController] associated with the
  /// given context.
  static CustomMediaController? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<MediaControllerProvider>();
    return result?.controller;
  }

  @override
  bool updateShouldNotify(covariant MediaControllerProvider oldWidget) =>
      controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CustomMediaController>(
      'controller',
      controller,
      ifNull: 'no controller',
      showName: false,
    ));
  }
}

///
extension MediaControllerProviderExtension on BuildContext {
  /// [CustomMediaController] instance
  CustomMediaController? get mediaController =>
      MediaControllerProvider.of(this);
}
