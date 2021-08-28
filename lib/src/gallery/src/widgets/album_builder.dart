import 'package:drishya_picker/src/gallery/src/controllers/gallery_repository.dart';
import 'package:flutter/material.dart';

///
class AlbumBuilder extends StatelessWidget {
  ///
  const AlbumBuilder({
    Key? key,
    required this.albums,
    this.builder,
    this.child,
  }) : super(key: key);

  ///
  final Albums albums;

  ///
  final Widget Function(BuildContext, AlbumsValue, Widget?)? builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumsValue>(
      valueListenable: albums,
      builder: builder ?? (_, __, child) => child ?? const SizedBox(),
      child: child,
    );
  }
}

///
class CurrentAlbumBuilder extends StatelessWidget {
  ///
  const CurrentAlbumBuilder({
    Key? key,
    required this.albums,
    this.builder,
    this.child,
  }) : super(key: key);

  ///
  final Albums albums;

  ///
  final Widget Function(BuildContext, Album, Widget?)? builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Album>(
      valueListenable: albums.currentAlbum,
      builder: builder ?? (_, __, child) => child ?? const SizedBox(),
      child: child,
    );
  }
}
