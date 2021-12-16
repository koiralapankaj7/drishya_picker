// ignore_for_file: always_use_package_imports, use_build_context_synchronously

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class GalleryViewField extends StatefulWidget {
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
    this.panelSetting,
    this.gallerySetting,
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
  /// [PanelSetting] passed to the [SlidableGalleryView] will be applicable..
  ///
  final PanelSetting? panelSetting;

  ///
  /// If used [GalleryViewField] with [SlidableGalleryView]
  /// this setting will be ignored.
  ///
  /// [GallerySetting] passed to the [SlidableGalleryView] will be applicable..
  ///
  final GallerySetting? gallerySetting;

  ///
  final Widget? child;

  @override
  State<GalleryViewField> createState() => _GalleryViewFieldState();
}

class _GalleryViewFieldState extends State<GalleryViewField> {
  late GalleryController _controller;
  bool _dispose = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_init);
  }

  void _init(Duration timeStamp) {
    if (context.galleryController == null) {
      _controller = GalleryController(
        panelSetting: widget.panelSetting,
        setting: widget.gallerySetting,
      );
      _dispose = true;
    } else {
      _controller = context.galleryController!;
    }
  }

  @override
  void dispose() {
    if (_dispose) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.openGallery(
          widget.onChanged,
          widget.onSubmitted,
          widget.selectedEntities,
          context,
        );
      },
      child: widget.child,
    );
  }
}
