import 'dart:math';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/album_builder.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
class GalleryHeader extends StatefulWidget {
  ///
  const GalleryHeader({
    Key? key,
    required this.controller,
    required this.onClose,
    required this.onAlbumToggle,
    required this.albums,
    this.headerSubtitle,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final String? headerSubtitle;

  ///
  final void Function() onClose;

  ///
  final void Function(bool visible) onAlbumToggle;

  ///
  final Albums albums;

  @override
  State<GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<GalleryHeader> {
  late final GalleryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final panelSetting = _controller.panelSetting;

    return Container(
      constraints: BoxConstraints(
        minHeight: panelSetting.thumbHandlerHeight,
        maxHeight: panelSetting.headerHeight + panelSetting.thumbHandlerHeight,
      ),
      color: panelSetting.headerBackground,
      child: Column(
        children: [
          // Handler
          _Handler(controller: _controller),

          // Details and controls
          Expanded(
            child: Row(
              children: [
                // Close icon
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _IconButton(
                      iconData: Icons.close,
                      onPressed: widget.onClose,
                    ),
                  ),
                ),

                // Album name and media receiver name
                FittedBox(
                  child: _AlbumDetail(
                    subtitle: widget.headerSubtitle,
                    controller: _controller,
                    albums: widget.albums,
                  ),
                ),

                // Dropdown
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      _AnimatedDropdown(
                        controller: _controller,
                        onPressed: widget.onAlbumToggle,
                        albumVisibility: _controller.albumVisibility,
                      ),
                      const Spacer(),
                      if (_controller.setting.selectionMode ==
                          SelectionMode.actionBased)
                        GalleryBuilder(
                          controller: _controller,
                          builder: (value, child) {
                            return InkWell(
                              onTap: () {
                                if (_controller.value.isAlbumVisible) {
                                  widget.onAlbumToggle(true);
                                } else {
                                  _controller.toogleMultiSelection();
                                }
                              },
                              child: Icon(
                                CupertinoIcons.rectangle_stack,
                                color: value.enableMultiSelection
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                //
              ],
            ),
          ),

          //
        ],
      ),
    );
  }
}

class _AnimatedDropdown extends StatelessWidget {
  const _AnimatedDropdown({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.albumVisibility,
  }) : super(key: key);

  final GalleryController controller;

  ///
  final void Function(bool visible) onPressed;

  ///
  final ValueNotifier<bool> albumVisibility;

  @override
  Widget build(BuildContext context) {
    return GalleryBuilder(
      controller: controller,
      builder: (value, child) {
        return AnimatedOpacity(
          opacity: value.selectedEntities.isEmpty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: albumVisibility,
        builder: (context, visible, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(
              begin: visible ? 0.0 : 1.0,
              end: visible ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 300),
            builder: (context, factor, child) {
              return Transform.rotate(
                angle: pi * factor,
                child: child,
              );
            },
            child: _IconButton(
              iconData: Icons.keyboard_arrow_down,
              onPressed: () {
                if (controller.value.selectedEntities.isEmpty) {
                  onPressed(visible);
                }
              },
              size: 34,
            ),
          );
        },
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    Key? key,
    this.iconData,
    this.onPressed,
    this.size,
  }) : super(key: key);

  final IconData? iconData;
  final void Function()? onPressed;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(40),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          iconData ?? Icons.close,
          color: Colors.lightBlue.shade300,
          size: size ?? 26.0,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _AlbumDetail extends StatelessWidget {
  const _AlbumDetail({
    Key? key,
    this.subtitle,
    required this.controller,
    required this.albums,
  }) : super(key: key);

  ///
  final String? subtitle;

  ///
  final GalleryController controller;

  ///
  final Albums albums;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album name
        CurrentAlbumBuilder(
          albums: albums,
          builder: (context, album, child) {
            final isAll = album.value.assetPathEntity?.isAll ?? true;

            return Text(
              isAll
                  ? controller.setting.albumTitle
                  : album.value.assetPathEntity?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),

        const SizedBox(height: 2),

        // Receiver name
        Text(
          subtitle ?? 'Select',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _Handler extends StatelessWidget {
  const _Handler({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.fullScreenMode) {
      return SizedBox(height: MediaQuery.of(context).padding.top);
    }

    return SizedBox(
      height: controller.panelSetting.thumbHandlerHeight,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 40,
            height: 5,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
