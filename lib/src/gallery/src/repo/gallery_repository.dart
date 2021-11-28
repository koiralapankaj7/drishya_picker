import 'dart:async';
import 'dart:developer';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

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

  /// Fetch recent entities
  Future<List<DrishyaEntity>> recentEntities({
    RequestType? type,
    int count = 20,
  }) async {
    // final state = await PhotoManager.requestPermissionExtend();
    // if (state == PermissionState.authorized) {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: type ?? RequestType.all,
      );
      if (albums.isEmpty) return [];
      final entities = await albums
          .singleWhere((element) => element.isAll)
          .getAssetListPaged(0, count);
      final drishyaEntities = entities.map((e) => e.toDrishya).toList();
      return drishyaEntities;
    } catch (e) {
      log('Exception fetching recent entities => $e');
      return [];
    }
    // } else {
    //   debugPrint('Permission denied');
    // }
  }

  /// Get album list
  Future<List<Album>> fetchAlbums(RequestType type) async {
    // final state = await PhotoManager.requestPermissionExtend();
    // if (state == PermissionState.authorized) {
    try {
      final albums = await PhotoManager.getAssetPathList(type: type);
      // Update album list
      final albumList = List.generate(albums.length, (index) {
        final album = Album(album: albums[index]);
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
      log('Exception fetching albums => $e');
      value = value.copyWith(error: e.toString(), state: BaseState.error);
      return [];
    }
    // }
    //  else {
    //   value.copyWith(
    //     error: 'Permission',
    //     state: BaseState.unauthorised,
    //   );
    //   return [];
    // }
  }

  ///
  void changeAlbum(Album album) {
    currentAlbum.value = album;
    album.fetchAssets();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

///
class Album extends ValueNotifier<AlbumValue> {
  ///
  Album({AssetPathEntity? album}) : super(AlbumValue(assetPathEntity: album));

  var _currentPage = 0;

  /// Get assets for the current album
  Future<List<AssetEntity>> fetchAssets() async {
    // final state = await PhotoManager.requestPermissionExtend();
    // if (state == PermissionState.authorized) {
    try {
      final entities =
          (await value.assetPathEntity?.getAssetListPaged(_currentPage, 30)) ??
              [];

      final updatedEntities = [...value.entities, ...entities];
      ++_currentPage;
      value = value.copyWith(
        state: BaseState.completed,
        entities: updatedEntities,
      );
    } catch (e) {
      log('Exception fetching assets => $e');
      value = value.copyWith(state: BaseState.error, error: e.toString());
    }
    // } else {
    //   value = value.copyWith(state: BaseState.unauthorised);
    // }

    return value.entities;
  }
}
