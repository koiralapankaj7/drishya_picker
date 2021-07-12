import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

import '../camera_view.dart';

///
/// Widget to pick media using camera
class CameraViewField extends StatelessWidget {
  ///
  const CameraViewField({
    Key? key,
    this.onCapture,
    this.child,
    this.videoDuration,
  }) : super(key: key);

  ///
  /// Triggered when picker capture media
  ///
  final void Function(DrishyaEntity entity)? onCapture;

  ///
  final Duration? videoDuration;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CameraView.pick(context, videoDuration: videoDuration).then((value) {
          if (value != null) {
            onCapture?.call(value);
          }
        });
      },
      child: child,
    );
  }
}
