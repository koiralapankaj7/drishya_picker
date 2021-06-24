import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

///
class UIHandler {
  ///
  UIHandler(this.context);

  ///
  final BuildContext context;

  /// Snackbar for error
  void showExceptionSnackbar(CameraException e) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
  }

  /// Snackbar for normal mesages
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  ///
  void pop<T extends Object?>([T? result]) =>
      Navigator.of(context).pop<T>(result);
}
