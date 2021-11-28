// ignore_for_file: always_use_package_imports

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/album_builder.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../gallery_view.dart';
import 'gallery_permission_view.dart';

const _imageSize = 48;

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
            padding: const EdgeInsets.only(top: 16),
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
        padding: const EdgeInsets.only(left: 16, bottom: 20, right: 16),
        color: Colors.black,
        child: Row(
          children: [
            // Image
            Container(
              height: _imageSize.toDouble(),
              width: _imageSize.toDouble(),
              color: Colors.grey.shade800,
              child: FutureBuilder<AssetEntity?>(
                future: _entity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.data == null) {
                    return const SizedBox();
                  }
                  return ColoredBox(
                    color: Colors.grey.shade800,
                    child: EntityThumbnail(entity: snapshot.data!.toDrishya),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

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
                  const SizedBox(height: 4),
                  // Total photos
                  Text(
                    album.value.assetPathEntity?.assetCount.toString() ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
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
