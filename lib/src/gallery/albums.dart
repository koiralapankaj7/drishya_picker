import 'dart:typed_data';

import 'package:drishya_picker/src/gallery/drishya_repository.dart';
import 'package:drishya_picker/src/gallery/permission_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class AlbumList extends StatelessWidget {
  ///
  const AlbumList({
    Key? key,
    required this.height,
    required this.albumsNotifier,
    this.onPressed,
  }) : super(key: key);

  ///
  final ValueNotifier<AlbumsType> albumsNotifier;

  ///
  final double height;

  ///
  final Function(AssetPathEntity album)? onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumsType>(
      valueListenable: albumsNotifier,
      builder: (context, state, child) {
        // Loading
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (state.hasError) {
          if (!state.hasPermission) {
            return const PermissionRequest();
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
        return Container(
          height: height,
          color: Colors.black,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
            itemCount: state.data!.length,
            itemBuilder: (context, index) {
              final entity = state.data![index];
              return _Album(
                entity: entity,
                onPressed: onPressed,
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
