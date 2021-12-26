// ignore_for_file: always_use_package_imports, use_build_context_synchronously

import 'package:drishya_picker/drishya_picker.dart';
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
    this.selectedEntities,
    this.setting,
    this.child,
  }) : super(key: key);

  ///
  /// While picking drishya using gallery removed will be true if,
  /// previously selected drishya is unselected otherwise false.
  ///
  final void Function(DrishyaEntity entity, bool removed)? onChanged;

  ///
  /// Triggered when picker complet its task.
  ///
  final void Function(List<DrishyaEntity> entities)? onSubmitted;

  ///
  /// Previously selected entities
  ///
  final List<DrishyaEntity>? selectedEntities;

  ///
  /// If used [GalleryViewField] with [SlidableGalleryView]
  /// this setting will be ignored.
  ///
  /// [GallerySetting] passed to the [SlidableGalleryView] will be applicable..
  ///
  final GallerySetting? setting;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        late GalleryController controller;
        if (context.galleryController == null) {
          controller = GalleryController();
        } else {
          controller = context.galleryController!;
        }
        controller.onGalleryFieldPressed(
          context,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          selectedEntities: selectedEntities,
          setting: setting,
        );
      },
      child: child ?? const Icon(Icons.image),
    );
  }
}
