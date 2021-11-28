// ignore_for_file: always_use_package_imports

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/lazy_load_scroll_view.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../entities/gallery_value.dart';
import '../gallery_view.dart';
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
                onEndOfPage: () => album.fetchAssets(),
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
  final DrishyaEntity entity;

  ///
  final ValueSetter<DrishyaEntity> onPressed;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    Uint8List? bytes;
    File? file;

    if (entity.type == AssetType.video || entity.type == AssetType.image) {
      child = AspectRatio(
        aspectRatio: 1,
        child: Image(
          image: MediaThumbnailProvider(media: entity),
          fit: BoxFit.cover,
        ),
      );
    }

    if (entity.type == AssetType.audio) {
      child = const Icon(Icons.audiotrack, color: Colors.white);
    }

    if (entity.type == AssetType.other) {
      child = const Center(child: Icon(Icons.folder, color: Colors.white));
    }

    child = Stack(
      fit: StackFit.expand,
      children: [
        child ?? const SizedBox(),
        if (entity.type == AssetType.video || entity.type == AssetType.audio)
          Positioned(
            right: 4,
            bottom: 4,
            child: _VideoDuration(duration: entity.videoDuration.inSeconds),
          ),
        if (!controller.singleSelection)
          _SelectionCount(controller: controller, entity: entity),
      ],
    );

    return ColoredBox(
      color: Colors.grey.shade800,
      child: InkWell(
        onTap: () {
          onPressed(entity.copyWith(thumbBytes: bytes, file: file));
        },
        child: child,
      ),
    );
  }
}

class _VideoDuration extends StatelessWidget {
  const _VideoDuration({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final int duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            duration.formatedDuration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
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
  final DrishyaEntity entity;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GalleryValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final isSelected = value.selectedEntities.contains(entity);
        // if (!isSelected) return const SizedBox();
        final index = value.selectedEntities.indexOf(entity);

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

///
extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString();
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}

/// ImageProvider implementation
@immutable
class MediaThumbnailProvider extends ImageProvider<MediaThumbnailProvider> {
  /// Constructor for creating a [MediaThumbnailProvider]
  const MediaThumbnailProvider({
    this.media,
    this.entity,
  }) : assert(
          media != null || entity != null,
          'Provide at least one media',
        );

  /// Media to load
  final DrishyaEntity? media;

  ///
  final AssetEntity? entity;

  @override
  ImageStreamCompleter load(
    MediaThumbnailProvider key,
    DecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: 1,
        informationCollector: () sync* {
          yield ErrorDescription('Id: ${media?.id ?? entity?.id}');
        },
      );

  Future<ui.Codec> _loadAsync(
    MediaThumbnailProvider key,
    DecoderCallback decode,
  ) async {
    assert(key == this, 'Checks MediaThumbnailProvider');
    if (entity != null) {
      final bytes = await entity!.thumbData;
      return decode(bytes!);
    }
    return decode(media!.thumbBytes);
  }

  @override
  Future<MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<MediaThumbnailProvider>(this);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    // ignore: test_types_in_equals
    final typedOther = other as MediaThumbnailProvider;
    return media?.id == typedOther.media?.id ||
        entity?.id == typedOther.entity?.id;
  }

  @override
  int get hashCode => media?.id.hashCode ?? entity!.id.hashCode;

  @override
  String toString() => '$MediaThumbnailProvider("${media?.id ?? entity?.id}")';
}
