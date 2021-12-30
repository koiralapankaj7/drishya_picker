// ignore_for_file: always_use_package_imports, use_build_context_synchronously

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';

///
class GalleryViewField extends StatelessWidget {
  ///
  /// Widget which pick media from gallery
  ///
  /// If used [GalleryViewField] with [SlidableGalleryView], [PanelSetting]
  /// and [GallerySetting] will be override by the [SlidableGalleryView]
  ///
  const GalleryViewField({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.setting,
    this.routeSetting,
    this.child,
  }) : super(key: key);

  ///
  /// While picking drishya using gallery removed will be true if,
  /// previously selected drishya is unselected otherwise false.
  ///
  final void Function(DrishyaEntity entity, bool removed)? onChanged;

  ///
  /// Triggered when picker complet its task.
  final ValueSetter<List<DrishyaEntity>>? onSubmitted;

  ///
  /// If used [GalleryViewField] with [SlidableGalleryView]
  /// this setting will be ignored.
  ///
  /// [GallerySetting] passed to the [SlidableGalleryView] will be applicable..
  ///
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
        late GalleryController controller;
        if (context.galleryController == null) {
          controller = GalleryController();
        } else {
          controller = context.galleryController!;
        }
        controller
            .onGalleryFieldPressed(
          context,
          onChanged: onChanged,
          setting: setting,
        )
            .then((entities) {
          onSubmitted?.call(entities);
        });
      },
      child: child ?? const Icon(Icons.image),
    );
  }
}
