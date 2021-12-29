import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:flutter/material.dart';

///
/// Widget to pick media using camera
class CameraViewField extends StatelessWidget {
  ///
  const CameraViewField({
    Key? key,
    required this.child,
    this.controller,
    this.setting,
    this.editorSetting,
    this.photoEditorSetting,
    this.routeSetting,
    this.onCapture,
  }) : super(key: key);

  ///
  /// Child widget
  final Widget child;

  ///
  /// Camera controller
  final CamController? controller;

  ///
  /// Settings related to the camera
  final CameraSetting? setting;

  ///
  /// Settings for text editor
  /// If setting is null default setting's will be used
  final EditorSetting? editorSetting;

  ///
  /// Setting for photo editing after taking picture,
  /// If this setting is null [editorSetting] will be used
  final EditorSetting? photoEditorSetting;

  ///
  /// Route setting
  final CustomRouteSetting? routeSetting;

  ///
  /// Triggered when picker capture media
  final void Function(List<DrishyaEntity> entities)? onCapture;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        CameraView.pick(
          context,
          controller: controller,
          setting: setting,
          editorSetting: editorSetting,
          photoEditorSetting: photoEditorSetting,
          routeSetting: routeSetting,
        ).then((entities) {
          if (entities?.isNotEmpty ?? false) {
            onCapture?.call(entities!);
          }
          UIHandler.showStatusBar();
        });
      },
      child: child,
    );
  }
}
