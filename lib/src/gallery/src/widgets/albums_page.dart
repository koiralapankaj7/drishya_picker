import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/album_builder.dart';
import 'package:flutter/material.dart';

const _imageSize = 48;

///
class AlbumsPage extends StatelessWidget {
  ///
  const AlbumsPage({
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
      controller: controller,
      albums: albums,
      hidePermissionView: true,
      builder: (context, value, child) {
        if (value.albums.isEmpty) {
          return Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: const Text(
              'No albums',
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
              return _AlbumTile(
                controller: controller,
                album: album,
                onPressed: onAlbumChange,
              );
            },
          ),
        );
      },
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    Key? key,
    required this.controller,
    required this.album,
    this.onPressed,
  }) : super(key: key);

  final GalleryController controller;
  final Album album;
  final ValueChanged<Album>? onPressed;

  Future<AssetEntity?> _entity() async {
    final assets = (await album.value.assetPathEntity
            ?.getAssetListPaged(page: 0, size: 1)) ??
        [];
    if (assets.isEmpty) return null;
    return assets.first;
  }

  @override
  Widget build(BuildContext context) {
    final isAll = album.value.assetPathEntity?.isAll ?? true;

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
                    isAll
                        ? 'All Photos'
                        : album.value.assetPathEntity?.name ?? '',
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
