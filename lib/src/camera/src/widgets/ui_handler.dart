import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
class UIHandler {
  ///
  UIHandler._internal(this._context);

  ///
  factory UIHandler.of(BuildContext context) => UIHandler._internal(context);

  ///
  final BuildContext _context;

  /// Navigator state for the [_context]
  NavigatorState get _state => Navigator.of(_context);

  /// If true, status bar will be visible other invisible on pop event.
  static bool showStatusBarOnPop = true;

  /// Hide status bar
  static Future<void> hideStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  /// Show status bar
  static Future<void> showStatusBar() async {
    if (!showStatusBarOnPop) return;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Snackbar for error
  void showExceptionSnackbar(CameraException e) {
    ScaffoldMessenger.of(_context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
  }

  /// Snackbar for normal mesages
  void showSnackBar(String message) {
    ScaffoldMessenger.of(_context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Pop widget
  void pop<T extends Object?>([T? result]) {
    (showStatusBarOnPop ? showStatusBar() : Future<void>.value()).then((value) {
      if (!_state.mounted) return;
      _state.pop<T?>(result);
    });
  }

  /// Pop widget and hide status bar
  void popAndHideStatusBar<T extends Object?>([T? result]) {
    hideStatusBar().then((value) {
      if (!_state.mounted) return;
      _state.pop<T?>(result);
    });
  }
}
