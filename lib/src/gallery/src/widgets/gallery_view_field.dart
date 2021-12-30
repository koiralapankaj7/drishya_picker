import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';

///
class GalleryViewField extends StatelessWidget {
  ///
  /// Widget which pick media from gallery
  ///
  /// If used [GalleryViewField] with [SlidableGallery], [PanelSetting]
  /// and [GallerySetting] will be override by the [SlidableGallery]
  ///
  const GalleryViewField({
    Key? key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.setting,
    this.routeSetting,
    this.child,
  }) : super(key: key);

  ///
  /// Gallery controller
  final GalleryController? controller;

  ///
  /// While picking drishya using gallery removed will be true if,
  /// previously selected drishya is unselected otherwise false.
  final void Function(DrishyaEntity entity, bool removed)? onChanged;

  ///
  /// Triggered when picker complet its task.
  final ValueSetter<List<DrishyaEntity>>? onSubmitted;

  ///
  /// If used [GalleryViewField] with [SlidableGallery]
  /// panel setting will be ignored from this setting.
  ///
  /// [GallerySetting] passed to the [SlidableGallery] will be applicable..
  final GallerySetting? setting;

  ///
  /// Route setting for gallery in fullscreen mode.
  final CustomRouteSetting? routeSetting;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Controller created here will be disposed by controller itself after
        // finishing its task.
        late GalleryController ctrl;
        var dispose = false;

        if (context.galleryController == null) {
          ctrl = controller ?? GalleryController();
          dispose = controller == null;
        } else {
          ctrl = context.galleryController!;
        }
        ctrl
            .onGalleryFieldPressed(
          context,
          onChanged: onChanged,
          setting: setting,
          disposeOnFinish: dispose,
        )
            .then((entities) {
          onSubmitted?.call(entities);
        });
      },
      child: child ?? const Icon(Icons.image),
    );
  }
}
