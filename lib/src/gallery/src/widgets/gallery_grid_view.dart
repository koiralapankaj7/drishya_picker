import 'dart:developer';
import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/widgets/lazy_load_scroll_view.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../controllers/gallery_repository.dart';
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
                  padding: const EdgeInsets.all(0.0),
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
                          size: 26.0,
                        ),
                      );
                    }

                    final ind =
                        controller.setting.enableCamera ? index - 1 : index;

                    final entity = albums.value.state == BaseState.fetching
                        ? null
                        : entities[ind];

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
  final AssetEntity? entity;

  ///
  final ValueSetter<DrishyaEntity> onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade800,
      child: entity == null
          ? const SizedBox.expand()
          : InkWell(
              onTap: () {
                // onPressed(dEntity);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: entity!.type == AssetType.video ||
                            entity!.type == AssetType.image
                        ? Image(image: MediaThumbnailProvider(media: entity!))
                        : const SizedBox(),
                  ),

                  // Duration
                  if (entity!.type == AssetType.video)
                    Positioned(
                      right: 4.0,
                      bottom: 4.0,
                      child: _VideoDuration(duration: entity!.duration),
                    ),

                  // Image selection overlay
                  // if (!controller.singleSelection)
                  // _SelectionCount(controller: controller, entity: dEntity),

                  //
                ],
              ),
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
      borderRadius: BorderRadius.circular(20.0),
      child: ColoredBox(
        color: Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          child: Text(
            duration.formatedDuration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.0,
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
              radius: 14.0,
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
class MediaThumbnailProvider extends ImageProvider<MediaThumbnailProvider> {
  /// Constructor for creating a [MediaThumbnailProvider]
  const MediaThumbnailProvider({
    required this.media,
  });

  /// Media to load
  final AssetEntity media;

  @override
  ImageStreamCompleter load(
          MediaThumbnailProvider key, DecoderCallback decode) =>
      MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: 1,
        informationCollector: () sync* {
          yield ErrorDescription('Id: ${media.id}');
        },
      );

  Future<ui.Codec> _loadAsync(
      MediaThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this, 'Checks MediaThumbnailProvider');
    final bytes = await media.thumbData;

    return decode(bytes!);
  }

  @override
  Future<MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<MediaThumbnailProvider>(this);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    // ignore: test_types_in_equals
    final typedOther = other as MediaThumbnailProvider;
    return media.id == typedOther.media.id;
  }

  @override
  int get hashCode => media.id.hashCode;

  @override
  String toString() => '$runtimeType("${media.id}")';
}


// import 'dart:io';
// import 'dart:typed_data';

// import 'package:drishya_picker/drishya_picker.dart';
// import 'package:drishya_picker/src/animations/animations.dart';
// import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';

// import '../controllers/gallery_repository.dart';
// import '../entities/gallery_value.dart';
// import '../gallery_view.dart';
// import 'gallery_permission_view.dart';

// class _SelectableMedia {
//   _SelectableMedia(this.file, this.bytes);
//   final File? file;
//   final Uint8List? bytes;
// }

// ///
// class GalleryGridView extends StatelessWidget {
//   ///
//   const GalleryGridView({
//     Key? key,
//     required this.controller,
//     required this.onCameraRequest,
//     required this.onSelect,
//     required this.entitiesNotifier,
//     required this.panelController,
//   }) : super(key: key);

//   ///
//   final GalleryController controller;

//   ///
//   final ValueSetter<BuildContext> onCameraRequest;

//   ///
//   final void Function(DrishyaEntity, BuildContext) onSelect;

//   ///
//   final ValueNotifier<EntitiesType> entitiesNotifier;

//   ///
//   final PanelController panelController;

//   @override
//   Widget build(BuildContext context) {
//     return ColoredBox(
//       color: controller.panelSetting.foregroundColor,
//       child: ValueListenableBuilder<EntitiesType>(
//         valueListenable: entitiesNotifier,
//         builder: (context, state, child) {
//           // Error
//           if (state.hasError) {
//             if (!state.hasPermission) {
//               return const GalleryPermissionView();
//             }
//           }

//           // No data
//           if (!state.isLoading && (state.data?.isEmpty ?? true)) {
//             return const Center(
//               child: Text(
//                 'No media available',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             );
//           }

//           final entities = state.isLoading ? <AssetEntity>[] : state.data!;

//           final itemCount = state.isLoading
//               ? 20
//               : controller.setting.enableCamera
//                   ? entities.length + 1
//                   : entities.length;

//           return GridView.builder(
//             controller: panelController.scrollController,
//             padding: const EdgeInsets.all(0.0),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: controller.setting.crossAxisCount ?? 3,
//               crossAxisSpacing: 1.5,
//               mainAxisSpacing: 1.5,
//             ),
//             itemCount: itemCount,
//             itemBuilder: (context, index) {
//               if (controller.setting.enableCamera && index == 0) {
//                 return InkWell(
//                   onTap: () => onCameraRequest(context),
//                   child: Icon(
//                     CupertinoIcons.camera,
//                     color: Colors.lightBlue.shade300,
//                     size: 26.0,
//                   ),
//                 );
//               }

//               final ind = controller.setting.enableCamera ? index - 1 : index;

//               final entity = state.isLoading ? null : entities[ind];

//               return _MediaTile(
//                 controller: controller,
//                 entity: entity,
//                 onPressed: (entity) {
//                   onSelect(entity, context);
//                 },
//               );
//             },
//           );

//           //
//         },
//       ),
//     );
//   }
// }

// ///
// class _MediaTile extends StatelessWidget {
//   ///
//   const _MediaTile({
//     Key? key,
//     required this.entity,
//     required this.controller,
//     required this.onPressed,
//   }) : super(key: key);

//   ///
//   final GalleryController controller;

//   ///
//   final AssetEntity? entity;

//   ///
//   final ValueSetter<DrishyaEntity> onPressed;

//   Future<_SelectableMedia?> _getMedia(AssetEntity? entity) async {
//     final bytes = await entity?.thumbDataWithSize(400, 400);
//     final file = await entity?.file;

//     if (bytes == null || file == null) return null;
//     return _SelectableMedia(file, bytes);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ColoredBox(
//       color: Colors.grey.shade800,
//       child: FutureBuilder<_SelectableMedia?>(
//         future: _getMedia(entity),
//         builder: (context, snapshot) {
//           final hasData = snapshot.connectionState == ConnectionState.done &&
//               snapshot.data != null;

//           if (hasData) {
//             final dEntity = DrishyaEntity(
//               entity: entity!,
//               bytes: snapshot.data!.bytes!,
//               file: snapshot.data!.file!,
//             );
//             return GestureDetector(
//               onTap: () {
//                 onPressed(dEntity);
//               },
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // Image
//                   Image.memory(
//                     snapshot.data!.bytes!,
//                     fit: BoxFit.cover,
//                     gaplessPlayback: true,
//                   ),

//                   // Duration
//                   if (entity!.type == AssetType.video)
//                     Positioned(
//                       right: 4.0,
//                       bottom: 4.0,
//                       child: _VideoDuration(duration: entity!.duration),
//                     ),

//                   // Image selection overlay
//                   if (!controller.singleSelection)
//                     _SelectionCount(controller: controller, entity: dEntity),

//                   //
//                 ],
//               ),
//             );
//           }

//           return const SizedBox();
//         },
//       ),
//     );
//   }
// }

// class _VideoDuration extends StatelessWidget {
//   const _VideoDuration({
//     Key? key,
//     required this.duration,
//   }) : super(key: key);

//   final int duration;

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: ColoredBox(
//         color: Colors.black.withOpacity(0.7),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
//           child: Text(
//             duration.formatedDuration,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 13.0,
//               color: Colors.white,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SelectionCount extends StatelessWidget {
//   const _SelectionCount({
//     Key? key,
//     required this.controller,
//     required this.entity,
//   }) : super(key: key);

//   final GalleryController controller;
//   final DrishyaEntity entity;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<GalleryValue>(
//       valueListenable: controller,
//       builder: (context, value, child) {
//         final isSelected = value.selectedEntities.contains(entity);
//         // if (!isSelected) return const SizedBox();
//         final index = value.selectedEntities.indexOf(entity);

//         final crossFadeState =
//             isSelected ? CrossFadeState.showFirst : CrossFadeState.showSecond;
//         final firstChild = ColoredBox(
//           color: Theme.of(context).primaryColor.withOpacity(0.3),
//           child: Center(
//             child: CircleAvatar(
//               backgroundColor: Theme.of(context).primaryColor,
//               radius: 14.0,
//               child: Text(
//                 '${index + 1}',
//                 style: Theme.of(context).textTheme.button?.copyWith(
//                       color: Theme.of(context).colorScheme.onPrimary,
//                     ),
//               ),
//             ),
//           ),
//         );
//         return AppAnimatedCrossFade(
//           firstChild: firstChild,
//           secondChild: const SizedBox(),
//           crossFadeState: crossFadeState,
//           duration: const Duration(milliseconds: 300),
//         );
//       },
//     );
//   }
// }

// ///
// extension on int {
//   String get formatedDuration {
//     final duration = Duration(seconds: this);
//     final min = duration.inMinutes.remainder(60).toString();
//     final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$min:$sec';
//   }
// }
