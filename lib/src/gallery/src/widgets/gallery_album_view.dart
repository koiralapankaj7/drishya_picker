import 'dart:typed_data';

import 'package:drishya_picker/src/gallery/src/controllers/drishya_repository.dart';
import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class GalleryAlbumView extends StatefulWidget {
  ///
  const GalleryAlbumView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final GalleryController controller;

  @override
  _GalleryAlbumViewState createState() => _GalleryAlbumViewState();
}

class _GalleryAlbumViewState extends State<GalleryAlbumView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumsType>(
      valueListenable: widget.controller.albumsNotifier,
      builder: (context, state, child) {
        // Loading
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (state.hasError) {
          if (!state.hasPermission) {
            return const GalleryPermissionView();
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Text(
              state.error ?? 'Something went wrong',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        if (state.data?.isEmpty ?? true) {
          return Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: const Text(
              'No data',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        // Album list
        return ColoredBox(
          color: Colors.black,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
            itemCount: state.data!.length,
            itemBuilder: (context, index) {
              final entity = state.data![index];
              return _Album(
                entity: entity,
                onPressed: (album) {
                  widget.controller.changeAlbum(album);
                },
                // widget.onPressed,
              );
            },
          ),
        );
      },
    );
  }
}

class _Album extends StatelessWidget {
  const _Album({
    Key? key,
    required this.entity,
    this.onPressed,
  }) : super(key: key);

  final AssetPathEntity entity;
  final imageSize = 48;
  final Function(AssetPathEntity album)? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed?.call(entity);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, bottom: 20.0, right: 16.0),
        color: Colors.black,
        child: Row(
          children: [
            // Image
            Container(
              height: imageSize.toDouble(),
              width: imageSize.toDouble(),
              color: Colors.grey,
              child: FutureBuilder<List<AssetEntity>>(
                future: entity.getAssetListPaged(0, 1),
                builder: (context, listSnapshot) {
                  if (listSnapshot.connectionState == ConnectionState.done &&
                      (listSnapshot.data?.isNotEmpty ?? false)) {
                    return FutureBuilder<Uint8List?>(
                      future: listSnapshot.data!.first
                          .thumbDataWithSize(imageSize * 5, imageSize * 5),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }

                        return const SizedBox();
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            const SizedBox(width: 16.0),

            // Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album name
                  Text(
                    entity.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Total photos
                  Text(
                    entity.assetCount.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}



// import 'dart:typed_data';

// import 'package:drishya_picker/src/gallery/src/controllers/drishya_repository.dart';
// import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
// import 'package:drishya_picker/src/gallery/src/widgets/gallery_builder.dart';
// import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
// import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';

// ///
// class GalleryAlbumView extends StatefulWidget {
//   ///
//   const GalleryAlbumView({
//     Key? key,
//     required this.controller,
//     required this.panelSetting,
//   }) : super(key: key);

//   ///
//   final GalleryController controller;

//   ///
//   final PanelSetting panelSetting;

//   @override
//   _GalleryAlbumViewState createState() => _GalleryAlbumViewState();
// }

// class _GalleryAlbumViewState extends State<GalleryAlbumView> {
//   @override
//   Widget build(BuildContext context) {
//     final max =
//         widget.panelSetting.maxHeight! - widget.panelSetting.headerMaxHeight;

//     final height = MediaQuery.of(context).size.height;

//     return GalleryBuilder(
//       controller: widget.controller,
//       builder: (value, child) {
//         final tween = Tween(
//           begin: Offset(0.0, value.isAlbumVisible ? max : 0.0),
//           end: Offset(
//             0.0,
//             value.isAlbumVisible ? widget.panelSetting.headerMaxHeight : height,
//           ),
//         );

//         return TweenAnimationBuilder<Offset>(
//           tween: tween,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.fastLinearToSlowEaseIn,
//           builder: (context, offset, child) => Transform.translate(
//             offset: offset,
//             child: child,
//           ),
//           child: child,
//         );
//       },
//       child: LayoutBuilder(builder: (context, constraints) {
//         return ValueListenableBuilder<AlbumsType>(
//           valueListenable: widget.controller.albumsNotifier,
//           builder: (context, state, child) {
//             // Loading
//             if (state.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             // Error
//             if (state.hasError) {
//               if (!state.hasPermission) {
//                 return const GalleryPermissionView();
//               }
//               return Container(
//                 alignment: Alignment.center,
//                 color: Colors.black,
//                 child: Text(
//                   state.error ?? 'Something went wrong',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               );
//             }

//             if (state.data?.isEmpty ?? true) {
//               return Container(
//                 alignment: Alignment.center,
//                 color: Colors.black,
//                 child: const Text(
//                   'No data',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               );
//             }

//             // Album list
//             return ColoredBox(
//               color: Colors.black,
//               child: ListView.builder(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 itemCount: state.data!.length,
//                 itemBuilder: (context, index) {
//                   final entity = state.data![index];
//                   return _Album(
//                     entity: entity,
//                     onPressed: (album) {
//                       widget.controller.changeAlbum(album);
//                     },
//                     // widget.onPressed,
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }

// class _Album extends StatelessWidget {
//   const _Album({
//     Key? key,
//     required this.entity,
//     this.onPressed,
//   }) : super(key: key);

//   final AssetPathEntity entity;
//   final imageSize = 48;
//   final Function(AssetPathEntity album)? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         onPressed?.call(entity);
//       },
//       child: Container(
//         padding: const EdgeInsets.only(left: 16.0, bottom: 20.0, right: 16.0),
//         color: Colors.black,
//         child: Row(
//           children: [
//             // Image
//             Container(
//               height: imageSize.toDouble(),
//               width: imageSize.toDouble(),
//               color: Colors.grey,
//               child: FutureBuilder<List<AssetEntity>>(
//                 future: entity.getAssetListPaged(0, 1),
//                 builder: (context, listSnapshot) {
//                   if (listSnapshot.connectionState == ConnectionState.done &&
//                       (listSnapshot.data?.isNotEmpty ?? false)) {
//                     return FutureBuilder<Uint8List?>(
//                       future: listSnapshot.data!.first
//                           .thumbDataWithSize(imageSize * 5, imageSize * 5),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.done &&
//                             snapshot.data != null) {
//                           return Image.memory(
//                             snapshot.data!,
//                             fit: BoxFit.cover,
//                           );
//                         }

//                         return const SizedBox();
//                       },
//                     );
//                   }
//                   return const SizedBox();
//                 },
//               ),
//             ),

//             const SizedBox(width: 16.0),

//             // Column
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Album name
//                   Text(
//                     entity.name,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 4.0),
//                   // Total photos
//                   Text(
//                     entity.assetCount.toString(),
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 13.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             //
//           ],
//         ),
//       ),
//     );
//   }
// }
