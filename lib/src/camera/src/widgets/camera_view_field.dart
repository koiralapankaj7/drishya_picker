import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

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
  final void Function(AssetEntity entity)? onCapture;

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
