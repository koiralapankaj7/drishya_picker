import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
import 'package:flutter/material.dart';

///
class AlbumBuilder extends StatelessWidget {
  ///
  const AlbumBuilder({
    super.key,
    required this.controller,
    required this.albums,
    this.builder,
    this.child,
    this.hidePermissionView = false,
  });

  ///
  final GalleryController controller;

  ///
  final Albums albums;

  ///
  final Widget Function(BuildContext, AlbumsValue, Widget?)? builder;

  ///
  final Widget? child;

  ///
  final bool hidePermissionView;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumsValue>(
      valueListenable: albums,
      builder: (context, value, child) {
        // Error
        if (value.state == BaseState.unauthorised &&
            value.albums.isEmpty &&
            !hidePermissionView) {
          return GalleryPermissionView(
            onRefresh: () {
              albums.fetchAlbums(controller.setting.requestType);
            },
          );
        }

        // No data
        if (value.state == BaseState.completed && value.albums.isEmpty) {
          return const Center(
            child: Text(
              'No albums available',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        if (value.state == BaseState.error) {
          return const Center(
            child: Text(
              'Something went wrong. Please try again!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return builder?.call(context, value, child) ??
            child ??
            const SizedBox();
      },
      child: child,
    );
  }
}

///
class CurrentAlbumBuilder extends StatelessWidget {
  ///
  const CurrentAlbumBuilder({
    super.key,
    required this.albums,
    this.builder,
    this.child,
  });

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
