import 'dart:math';

import 'package:drishya_picker/src/gallery/src/controllers/drishya_repository.dart';
import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:flutter/material.dart';

///
class GalleryHeader extends StatefulWidget {
  ///
  const GalleryHeader({
    Key? key,
    required this.controller,
    required this.onClose,
    required this.onAlbumToggle,
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

  @override
  _GalleryHeaderState createState() => _GalleryHeaderState();
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
        minHeight: panelSetting.headerMinHeight,
        maxHeight: panelSetting.headerMaxHeight,
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
                    alignment: Alignment.topLeft,
                    child: _IconButton(
                      iconData: Icons.close,
                      onPressed: widget.onClose,
                    ),
                  ),
                ),

                // Album name and media receiver name
                _AlbumDetail(
                  subtitle: widget.headerSubtitle,
                  controller: _controller,
                ),

                // Dropdown
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: _AnimatedDropdown(
                        controller: _controller,
                        onPressed: widget.onAlbumToggle,
                      ),
                    ),
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
  }) : super(key: key);

  final GalleryController controller;

  ///
  final void Function(bool visible) onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.albumVisibilityNotifier,
      builder: (context, visible, child) {
        return Visibility(
          visible: !controller.singleSelection ||
              controller.value.selectedEntities.isEmpty,
          child: TweenAnimationBuilder<double>(
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
              onPressed: () => onPressed(visible),
              size: 34.0,
            ),
          ),
        );
      },
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
      borderRadius: BorderRadius.circular(40.0),
      elevation: 0.0,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
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
  }) : super(key: key);

  ///
  final String? subtitle;

  ///
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album name
        ValueListenableBuilder<AlbumType>(
          valueListenable: controller.albumNotifier,
          builder: (context, album, child) {
            return Text(
              album.data?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),

        const SizedBox(height: 2.0),

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
      height: controller.panelSetting.headerMinHeight,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            width: 40.0,
            height: 5.0,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
