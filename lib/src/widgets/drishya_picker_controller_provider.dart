import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../drishya_picker.dart';

///
class DrishyaPickerControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [DrishyaPickerController] with a subtree.
  const DrishyaPickerControllerProvider({
    Key? key,
    required DrishyaPickerController this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [DrishyaPickerController].
  const DrishyaPickerControllerProvider.none({
    Key? key,
    required Widget child,
  })   : controller = null,
        super(key: key, child: child);

  /// The [DrishyaPickerController] associated with the subtree.
  ///
  final DrishyaPickerController? controller;

  /// Returns the [DrishyaPickerController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [DrishyaPickerController] associated with the
  /// given context.
  static DrishyaPickerController? of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<DrishyaPickerControllerProvider>();
    return result?.controller;
  }

  @override
  bool updateShouldNotify(
          covariant DrishyaPickerControllerProvider oldWidget) =>
      controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DrishyaPickerController>(
      'controller',
      controller,
      ifNull: 'no controller',
      showName: false,
    ));
  }
}

///
extension MediaControllerProviderExtension on BuildContext {
  /// [DrishyaPickerController] instance
  DrishyaPickerController? get mediaController =>
      DrishyaPickerControllerProvider.of(this);
}
