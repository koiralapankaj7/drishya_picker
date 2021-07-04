import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'gallery_controller_provider.dart';

///
class GalleryViewField extends StatefulWidget {
  ///
  /// Widget which pick media from gallery
  ///
  /// If used [GalleryViewField] with [GalleryViewWrapper], [PanelSetting]
  /// and [GallerySetting] will be override by the [GalleryViewWrapper]
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
  final void Function(AssetEntity entity, bool removed)? onChanged;

  ///
  /// Triggered when picker complet its task.
  ///
  final void Function(List<AssetEntity> entities)? onSubmitted;

  ///
  /// Pre selected entities
  ///
  final List<AssetEntity>? selectedEntities;

  ///
  /// If used [GalleryViewField] with [GalleryViewWrapper]
  /// this setting will be ignored.
  ///
  /// [PanelSetting] passed to the [GalleryViewWrapper] will be applicable..
  ///
  final PanelSetting? panelSetting;

  ///
  /// If used [GalleryViewField] with [GalleryViewWrapper]
  /// this setting will be ignored.
  ///
  /// [GallerySetting] passed to the [GalleryViewWrapper] will be applicable..
  ///
  final GallerySetting? gallerySetting;

  ///
  final Widget? child;

  @override
  _GalleryViewFieldState createState() => _GalleryViewFieldState();
}

class _GalleryViewFieldState extends State<GalleryViewField> {
  late final GalleryController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _controller = context.galleryController ??
          GalleryController(
            panelSetting: widget.panelSetting,
            gallerySetting: widget.gallerySetting,
          );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
