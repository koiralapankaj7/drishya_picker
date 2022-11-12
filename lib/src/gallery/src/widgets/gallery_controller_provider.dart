// ignore_for_file: always_use_package_imports

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
class GalleryControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [GalleryController] with a subtree.
  const GalleryControllerProvider({
    super.key,
    required GalleryController this.controller,
    required super.child,
  });

  /// Creates a subtree without an associated [GalleryController].
  const GalleryControllerProvider.none({
    super.key,
    required super.child,
  })  : controller = null;

  /// The [GalleryController] associated with the subtree.
  ///
  final GalleryController? controller;

  /// Returns the [GalleryController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [GalleryController] associated with the
  /// given context.
  static GalleryController? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<GalleryControllerProvider>();
    return result?.controller;
  }

  @override
  bool updateShouldNotify(covariant GalleryControllerProvider oldWidget) =>
      controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<GalleryController>(
        'controller',
        controller,
        ifNull: 'no controller',
        showName: false,
      ),
    );
  }
}

///
extension GalleryControllerProviderExtension on BuildContext {
  /// [GalleryController] instance
  GalleryController? get galleryController =>
      GalleryControllerProvider.of(this);
}
