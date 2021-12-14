// ignore_for_file: always_use_package_imports

import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/lazy_load_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../entities/gallery_value.dart';
import 'album_builder.dart';
import 'gallery_permission_view.dart';

///
class GalleryGridView extends StatelessWidget {
  ///
  const GalleryGridView({
    Key? key,
    required this.controller,
    required this.onCameraRequest,
    required this.onSelect,
    required this.albums,
    required this.panelController,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final ValueSetter<BuildContext> onCameraRequest;

  ///
  final void Function(DrishyaEntity, BuildContext) onSelect;

  ///
  final Albums albums;

  ///
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: controller.panelSetting.foregroundColor,
      child: CurrentAlbumBuilder(
        albums: albums,
        builder: (context, album, child) {
          return ValueListenableBuilder<AlbumValue>(
            valueListenable: album,
            builder: (context, value, child) {
              // Error
              if (value.state == BaseState.unauthorised &&
                  value.entities.isEmpty) {
                return const GalleryPermissionView();
              }

              // No data
              if (value.state == BaseState.completed &&
                  value.entities.isEmpty) {
                return const Center(
                  child: Text(
                    'No media available',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final entities = value.entities;

              final itemCount = albums.value.state == BaseState.fetching
                  ? 20
                  : controller.setting.enableCamera
                      ? entities.length + 1
                      : entities.length;

              return LazyLoadScrollView(
                onEndOfPage: album.fetchAssets,
                scrollOffset: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  controller: panelController.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: controller.setting.crossAxisCount ?? 3,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (controller.setting.enableCamera && index == 0) {
                      return InkWell(
                        onTap: () => onCameraRequest(context),
                        child: Icon(
                          CupertinoIcons.camera,
                          color: Colors.lightBlue.shade300,
                          size: 26,
                        ),
                      );
                    }

                    final ind =
                        controller.setting.enableCamera ? index - 1 : index;

                    final entity = albums.value.state == BaseState.fetching
                        ? null
                        : entities[ind];

                    if (entity == null) return const SizedBox();

                    return _MediaTile(
                      controller: controller,
                      entity: entity,
                      onPressed: (entity) {
                        onSelect(entity, context);
                      },
                    );
                  },
                ),
              );
            },
          );

          //
        },
      ),
    );
  }
}

///
class _MediaTile extends StatelessWidget {
  ///
  const _MediaTile({
    Key? key,
    required this.entity,
    required this.controller,
    required this.onPressed,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final AssetEntity entity;

  ///
  final ValueSetter<DrishyaEntity> onPressed;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;

    final drishya = entity.toDrishya;

    return ColoredBox(
      color: Colors.grey.shade800,
      child: InkWell(
        onTap: () {
          onPressed(
            drishya.copyWith(pickedThumbData: bytes),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            EntityThumbnail(
              entity: drishya,
              onBytesGenerated: (b) {
                bytes = b;
              },
            ),
            if (!controller.singleSelection)
              _SelectionCount(controller: controller, entity: entity),
          ],
        ),
      ),
    );
  }
}

class _SelectionCount extends StatelessWidget {
  const _SelectionCount({
    Key? key,
    required this.controller,
    required this.entity,
  }) : super(key: key);

  final GalleryController controller;
  final AssetEntity entity;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GalleryValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final isSelected = value.selectedEntities.contains(entity);
        // if (!isSelected) return const SizedBox();
        final index = value.selectedEntities.indexOf(entity.toDrishya);

        final crossFadeState =
            isSelected ? CrossFadeState.showFirst : CrossFadeState.showSecond;
        final firstChild = ColoredBox(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          child: Center(
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 14,
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.button?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          ),
        );
        return AppAnimatedCrossFade(
          firstChild: firstChild,
          secondChild: const SizedBox(),
          crossFadeState: crossFadeState,
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
