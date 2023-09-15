import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/camera/src/entities/singleton.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
import 'package:flutter/material.dart';

///
class AlbumBuilder extends StatelessWidget {
  ///
  const AlbumBuilder({
    Key? key,
    required this.controller,
    required this.albums,
    this.builder,
    this.child,
    this.hidePermissionView = false,
  }) : super(key: key);

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
          return  Center(
            child: Text(
              Singleton.textDelegate.noAlbumsAvailable,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        if (value.state == BaseState.error) {
          return  Center(
            child: Text(
              Singleton.textDelegate.somethingWrong,
              style:const TextStyle(
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
