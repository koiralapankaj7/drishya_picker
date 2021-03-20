part of '../drishya_picker.dart';

/// Media Picker
class MediaPicker extends StatefulWidget {
  ///
  const MediaPicker({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.setting,
    this.child,
  }) : super(key: key);

  ///
  final void Function(AssetEntity entity, bool removed)? onChanged;

  ///
  final void Function(List<AssetEntity> entities)? onSubmitted;

  ///
  final DrishyaSetting? setting;

  ///
  final Widget? child;

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.mediaController!._fromPicker(
          widget.onChanged,
          widget.onSubmitted,
          widget.setting!,
        );
      },
      child: widget.child,
    );
  }
}
