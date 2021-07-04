import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
/// Widget to pick media using camera
class CameraViewField extends StatelessWidget {
  ///
  const CameraViewField({
    Key? key,
    this.onCapture,
    this.child,
  }) : super(key: key);

  ///
  /// Triggered when picker capture media
  ///
  final void Function(AssetEntity entity)? onCapture;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // DrishyaController()._openCamera(onCapture, context);
      },
      child: child,
    );
  }
}
