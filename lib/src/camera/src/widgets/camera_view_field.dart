// ignore_for_file: always_use_package_imports

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
/// Widget to pick media using camera
class CameraViewField extends StatelessWidget {
  ///
  const CameraViewField({
    Key? key,
    this.onCapture,
    this.controller,
    this.child,
  }) : super(key: key);

  ///
  /// Triggered when picker capture media
  ///
  final void Function(DrishyaEntity entity)? onCapture;

  /// Camera controller
  final CamController? controller;

  /// Child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CameraView.pick(context, controller: controller).then((value) {
          if (value != null) {
            onCapture?.call(value);
          }
        });
      },
      child: child,
    );
  }
}
