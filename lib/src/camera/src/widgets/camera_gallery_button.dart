import 'dart:developer';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:flutter/material.dart';

///
class CameraGalleryButton extends StatelessWidget {
  ///
  const CameraGalleryButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        final state = value.hideCameraGalleryButton
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond;

        return Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 44,
            height: 44,
            child: AppAnimatedCrossFade(
              firstChild: const SizedBox(),
              secondChild: const _GalleyView(),
              crossFadeState: state,
            ),
          ),
        );
      },
    );
  }
}

class _GalleyView extends StatefulWidget {
  const _GalleyView({Key? key}) : super(key: key);

  @override
  _GalleyViewState createState() => _GalleyViewState();
}

class _GalleyViewState extends State<_GalleyView> {
  late final GalleryController _controller;
  late final Future<List<DrishyaEntity>> _recent;

  @override
  void initState() {
    super.initState();
    _controller = GalleryController();
    _recent = _controller.recentEntities(count: 1);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final entities = await _controller.pick(
          context,
          setting: const GallerySetting(
            showCameraInsideGrid: false,
            showMultiSelectionButton: true,
            albumTitle: 'Gallery',
            panelSetting: PanelSetting(thumbHandlerHeight: 0),
          ),
        );
        log('$entities');
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: FutureBuilder<List<DrishyaEntity>>(
            future: _recent,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  (snapshot.data?.isNotEmpty ?? false)) {
                return EntityThumbnail(entity: snapshot.data!.first);
              }

              return const Icon(
                Icons.image_outlined,
                size: 28,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}
