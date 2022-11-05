import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/foundation.dart';

/// State for the fetching process
enum BaseState {
  /// Permission to access the asset has not been requested yet.
  unauthorised,

  /// Fetching assets is in progress.
  fetching,

  /// Fetching assets has completed.
  completed,

  /// Error occurred while fetching assets.
  error,
}

// Albums =>
///
class AlbumsValue {
  ///
  const AlbumsValue({
    this.albums = const <Album>[],
    this.error,
    this.state = BaseState.fetching,
  });

  ///
  final List<Album> albums;

  ///
  final String? error;

  ///
  final BaseState state;

  ///
  AlbumsValue copyWith({
    List<Album>? albums,
    String? error,
    BaseState? state,
  }) =>
      AlbumsValue(
        albums: albums ?? this.albums,
        error: error ?? this.error,
        state: state ?? this.state,
      );
}

///
class AlbumValue {
  ///
  const AlbumValue({
    this.assetPathEntity,
    this.entities = const <AssetEntity>[],
    this.state = BaseState.fetching,
    this.error,
  });

  ///
  final AssetPathEntity? assetPathEntity;

  ///
  final List<AssetEntity> entities;

  ///
  final BaseState state;

  ///
  final String? error;

  ///
  AlbumValue copyWith({
    AssetPathEntity? assetPathEntity,
    List<AssetEntity>? entities,
    String? error,
    BaseState? state,
  }) =>
      AlbumValue(
        assetPathEntity: assetPathEntity ?? this.assetPathEntity,
        entities: entities ?? this.entities,
        error: error ?? this.error,
        state: state ?? this.state,
      );
}

///
class Albums extends ValueNotifier<AlbumsValue> {
  ///
  Albums()
      : currentAlbum = ValueNotifier(Album()),
        super(const AlbumsValue());

  ///
  final ValueNotifier<Album> currentAlbum;

  // void _text() async {
  //   final so = compute(_another, '');
  // }

  // String _another(String args) {
  //   return '';
  // }

  /// Fetch recent entities
  Future<List<DrishyaEntity>> recentEntities({
    RequestType? type,
    int count = 20,
    ValueSetter<Exception>? onException,
  }) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(
          type: type ?? RequestType.all,
        );
        if (albums.isEmpty) return [];
        final entities = await albums
            .singleWhere((element) => element.isAll)
            .getAssetListPaged(page: 0, size: count);
        final drishyaEntities = entities.map((e) => e.toDrishya).toList();
        return drishyaEntities;
      } catch (e) {
        debugPrint('Exception fetching recent entities => $e');
        onException?.call(Exception(e));
        return [];
      }
    } else {
      onException?.call(Exception('Permission unavailable!'));
      return [];
    }
  }

  /// Get album list
  Future<List<Album>> fetchAlbums(RequestType type) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(type: type);
        // Update album list
        final albumList = List.generate(albums.length, (index) {
          final album = Album(
            albumValue: AlbumValue(assetPathEntity: albums[index]),
          );
          if (index == 0) {
            currentAlbum.value = album;
            album.fetchAssets();
          }
          return album;
        });
        value = value.copyWith(
          state: BaseState.completed,
          albums: albumList,
        );
        return albumList;
      } catch (e) {
        debugPrint('Exception fetching albums => $e');
        value = value.copyWith(error: e.toString(), state: BaseState.error);
        return [];
      }
    } else {
      value =
          value.copyWith(error: 'Permission', state: BaseState.unauthorised);
      currentAlbum.value = Album(
        albumValue: const AlbumValue(state: BaseState.unauthorised),
      );
      return [];
    }
  }

  ///
  void changeAlbum(Album album) {
    currentAlbum.value = album;
    album.fetchAssets();
  }

  @override
  void dispose() {
    currentAlbum.dispose();
    super.dispose();
  }
}

///
class Album extends ValueNotifier<AlbumValue> {
  ///
  Album({AlbumValue? albumValue}) : super(albumValue ?? const AlbumValue());

  var _currentPage = 0;

  /// Get assets for the current album
  Future<List<AssetEntity>> fetchAssets() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final entities = (await value.assetPathEntity
                ?.getAssetListPaged(page: _currentPage, size: 30)) ??
            [];

        final updatedEntities = [...value.entities, ...entities];
        ++_currentPage;
        value = value.copyWith(
          state: BaseState.completed,
          entities: updatedEntities,
        );
      } catch (e) {
        debugPrint('Exception fetching assets => $e');
        value = value.copyWith(state: BaseState.error, error: e.toString());
      }
    } else {
      value = value.copyWith(state: BaseState.unauthorised);
    }
    return value.entities;
  }

  /// Insert entity into album
  void insert(AssetEntity entity) {
    if (value.entities.isEmpty) return;
    value = value.copyWith(entities: [entity, ...value.entities]);
  }
}
