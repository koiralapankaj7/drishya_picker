import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'camera/camera_view.dart';
import 'entities/entities.dart';

/// Media Picker
class DrishyaPickerField extends StatefulWidget {
  ///
  const DrishyaPickerField({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.setting,
    this.child,
  }) : super(key: key);

  ///
  /// If source is [DrishyaSource.camera] [removed] will be always false
  ///
  /// While picking drishya using gallery [removed] will be true if,
  /// previously selected drishya is unselected otherwise false.
  ///
  final void Function(AssetEntity entity, bool removed)? onChanged;

  ///
  /// Triggered when picker complet its task.
  ///
  final void Function(List<AssetEntity> entities)? onSubmitted;

  ///
  /// Setting for drishya picker
  final DrishyaSetting? setting;

  ///
  final Widget? child;

  @override
  _DrishyaPickerFieldState createState() => _DrishyaPickerFieldState();
}

class _DrishyaPickerFieldState extends State<DrishyaPickerField> {
  late final DrishyaSetting setting;
  // late final DrishyaController controller;

  @override
  void initState() {
    super.initState();
    setting = widget.setting ?? DrishyaSetting();
  }

  void _onPressed() async {
    // If source is camera
    if (setting.source == DrishyaSource.camera) {
      final entity = await Navigator.of(context).push<AssetEntity?>(
        MaterialPageRoute(builder: (context) => CameraView()),
      );
      if (entity != null) {
        widget.onChanged?.call(entity, false);
        widget.onSubmitted?.call([entity]);
      }
    }

    if (setting.source == DrishyaSource.gallery) {
      if (setting.fullScreenMode) {
        // use naviagation
      } else {
        // use controller
        // assert(
        //   context.drishyaController != null,
        //   'It seems like you have\'nt wrap your root widget by [DrishyaPicker].',
        // );
        // context.drishyaController!._fromPicker(
        //   widget.onChanged,
        //   widget.onSubmitted,
        //   widget.setting,
        //   context,
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: widget.child,
    );
  }
}
