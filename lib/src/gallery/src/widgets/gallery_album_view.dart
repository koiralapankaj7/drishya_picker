import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/album_builder.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../gallery_view.dart';
import 'gallery_permission_view.dart';

///
class GalleryAlbumView extends StatelessWidget {
  ///
  const GalleryAlbumView({
    Key? key,
    required this.controller,
    required this.onAlbumChange,
    required this.albums,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final ValueSetter<Album> onAlbumChange;

  ///
  final Albums albums;

  @override
  Widget build(BuildContext context) {
    return AlbumBuilder(
      albums: albums,
      builder: (context, value, child) {
        // Loading
        if (value.state == BaseState.fetching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (value.state == BaseState.unauthorised) {
          return const GalleryPermissionView();
        }

        // Error
        if (value.state == BaseState.error) {
          return Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Text(
              value.error ?? 'Something went wrong',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        if (value.albums.isEmpty) {
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
            itemCount: value.albums.length,
            itemBuilder: (context, index) {
              final album = value.albums[index];
              return _Album(album: album, onPressed: onAlbumChange);
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
    required this.album,
    this.onPressed,
  }) : super(key: key);

  final Album album;
  final imageSize = 48;
  final Function(Album album)? onPressed;

  Future<AssetEntity?> _entity() async {
    final assets =
        (await album.value.assetPathEntity?.getAssetListPaged(0, 1)) ?? [];
    if (assets.isEmpty) return null;
    return assets.first;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed?.call(album);
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
              child: FutureBuilder<AssetEntity?>(
                future: _entity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.data == null) {
                    return const SizedBox();
                  }

                  return _MediaTile(entity: snapshot.data!);
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
                    album.value.assetPathEntity?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Total photos
                  Text(
                    album.value.assetPathEntity?.assetCount.toString() ?? '',
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

class _MediaTile extends StatelessWidget {
  ///
  const _MediaTile({
    Key? key,
    required this.entity,
  }) : super(key: key);

  ///
  final AssetEntity entity;

  @override
  Widget build(BuildContext context) {
    Widget? child;

    if (entity.type == AssetType.video || entity.type == AssetType.image) {
      child = AspectRatio(
        aspectRatio: 1,
        child: Image(
          image: MediaThumbnailProvider(entity: entity),
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

    return ColoredBox(
      color: Colors.grey.shade800,
      child: child,
    );
  }
}
