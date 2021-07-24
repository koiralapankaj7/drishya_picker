import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
typedef AlbumsType = BaseState<List<AssetPathEntity>>;

///
typedef AlbumType = BaseState<AssetPathEntity>;

///
typedef EntitiesType = BaseState<List<AssetEntity>>;

///
class GalleryRepository {
  ///
  const GalleryRepository({
    required this.albumsNotifier,
    required this.albumNotifier,
    required this.entitiesNotifier,
    required this.recentEntitiesNotifier,
  });

  ///
  final ValueNotifier<AlbumsType> albumsNotifier;

  ///
  final ValueNotifier<AlbumType> albumNotifier;

  ///
  final ValueNotifier<EntitiesType> entitiesNotifier;

  ///
  final ValueNotifier<EntitiesType> recentEntitiesNotifier;

  /// Get album list
  void fetchAlbums(RequestType type) async {
    albumsNotifier.value = const BaseState(isLoading: true);
    albumNotifier.value = const BaseState(isLoading: true);
    entitiesNotifier.value = const BaseState(isLoading: true);

    // final state = await PhotoManager.requestPermissionExtend();
    // if (state == PermissionState.authorized) {
    try {
      // final options = FilterOptionGroup()
      //   ..setOption(
      //     type.assetType,
      //     const FilterOption(
      //       needTitle: true,
      //       sizeConstraint: SizeConstraint(ignoreSize: true),
      //     ),
      //   );

      final albums = await PhotoManager.getAssetPathList(type: type);

      // Update album list
      albumsNotifier.value = BaseState(data: albums, hasPermission: true);

      final album = albums.isNotEmpty ? albums.first : null;
      // Update selected album
      albumNotifier.value = BaseState(data: album, hasPermission: true);

      final entities = await album?.assetList ?? <AssetEntity>[];
      // Update selected album entities list
      entitiesNotifier.value = BaseState(data: entities, hasPermission: true);
    } catch (e) {
      albumsNotifier.value = BaseState(
        hasPermission: false,
        hasError: true,
        error: e.toString(),
      );
      entitiesNotifier.value = BaseState(
        hasPermission: false,
        hasError: true,
        error: e.toString(),
      );
    }
    // } else {
    //   albumsNotifier.value = const BaseState(
    //     hasError: true,
    //     error: 'Permission denied',
    //   );
    //   entitiesNotifier.value = const BaseState(
    //     hasError: true,
    //     error: 'Permission denied',
    //   );
    // }
  }

  /// Get assets for specific [album]
  void fetchAssetsFor(AssetPathEntity album) async {
    albumNotifier.value = albumNotifier.value.copyWith(data: album);
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final entities = await album.assetList;
        entitiesNotifier.value = BaseState(data: entities, hasPermission: true);
        recentEntitiesNotifier.value =
            BaseState(data: entities, hasPermission: true);
      } catch (e) {
        entitiesNotifier.value = BaseState(
          hasPermission: true,
          hasError: true,
          error: e.toString(),
        );
      }
    } else {
      entitiesNotifier.value = const BaseState(
        hasError: true,
        error: 'Permission denied',
      );
    }
  }

  ///
}

///
class BaseState<T> {
  ///
  const BaseState({
    this.data,
    this.error = '',
    this.isLoading = false,
    this.hasError = false,
    this.hasPermission = false,
  });

  ///
  final T? data;

  ///
  final String? error;

  ///
  final bool isLoading;

  ///
  final bool hasPermission;

  ///
  final bool hasError;

  ///
  BaseState<T> copyWith({
    T? data,
    String? error,
    bool? isLoading,
    bool? hasPermission,
    bool? hasError,
  }) =>
      BaseState<T>(
        data: data ?? this.data,
        error: error ?? this.error,
        isLoading: isLoading ?? this.isLoading,
        hasPermission: hasPermission ?? this.hasPermission,
        hasError: hasError ?? this.hasError,
      );
}

///
extension RequestTypeExtension on RequestType {
  ///
  AssetType get assetType {
    switch (this) {
      case RequestType.image:
        return AssetType.image;
      case RequestType.video:
        return AssetType.video;
      case RequestType.audio:
        return AssetType.audio;
      default:
        return AssetType.other;
    }
  }
}
