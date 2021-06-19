import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

final mediaFetcher = MediaFetcher();

final ValueNotifier<AssetPathEntity?> currentAlbum = ValueNotifier(null);
final ValueNotifier<List<AssetEntity>> albumEntities = ValueNotifier([]);

class MediaFetcher extends ValueNotifier<MediaValue> {
  MediaFetcher() : super(MediaValue());

  /// Get album list
  void getAlbumList(RequestType type) async {
    value = value.copyWith(isLoading: true);
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(type: type);
        final album = albums.isNotEmpty ? albums.first : null;
        currentAlbum.value = album;
        final entities = await album?.assetList ?? <AssetEntity>[];
        albumEntities.value = entities;
        value = value.copyWith(
          albums: albums,
          album: album,
          entities: entities,
          isLoading: false,
          hasError: false,
          hasPermission: true,
        );
      } catch (e) {
        value = value.copyWith(
          error: e.toString(),
          isLoading: false,
          hasError: true,
          hasPermission: true,
        );
      }
    } else {
      value = value.copyWith(
        error: 'Permission denied',
        isLoading: false,
        hasError: true,
        hasPermission: false,
      );
    }
  }

  /// Get assets for specific [album]
  void getAssetsFor(AssetPathEntity album) async {
    currentAlbum.value = album;
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final entities = await album.assetList;
        albumEntities.value = entities;
      } catch (e) {
        value = value.copyWith(
          error: e.toString(),
          isLoading: false,
          hasError: true,
          hasPermission: true,
        );
      }
    } else {
      value = value.copyWith(
        error: 'Permission denied',
        isLoading: false,
        hasError: true,
        hasPermission: false,
      );
    }
  }

  ///
}

///
class MediaValue {
  ///
  const MediaValue({
    this.albums = const <AssetPathEntity>[],
    this.album,
    this.entities = const <AssetEntity>[],
    this.error = '',
    this.isLoading = false,
    this.hasError = false,
    this.hasPermission = false,
  });

  ///
  final List<AssetPathEntity> albums;

  ///
  final AssetPathEntity? album;

  ///
  final List<AssetEntity> entities;

  ///
  final String? error;

  ///
  final bool isLoading;

  ///
  final bool hasPermission;

  ///
  final bool hasError;

  ///
  MediaValue copyWith({
    List<AssetPathEntity>? albums,
    AssetPathEntity? album,
    List<AssetEntity>? entities,
    String? error,
    bool? isLoading,
    bool? hasPermission,
    bool? hasError,
  }) =>
      MediaValue(
        albums: albums ?? this.albums,
        album: album ?? this.album,
        entities: entities ?? this.entities,
        error: error ?? this.error,
        isLoading: isLoading ?? this.isLoading,
        hasPermission: hasPermission ?? this.hasPermission,
        hasError: hasError ?? this.hasError,
      );
}
