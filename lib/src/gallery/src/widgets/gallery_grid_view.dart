import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/controllers/drishya_repository.dart';
import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:drishya_picker/src/gallery/src/entities/gallery_value.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class GalleryGridView extends StatelessWidget {
  ///
  const GalleryGridView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: controller.panelSetting.foregroundColor,
      child: ValueListenableBuilder<EntitiesType>(
        valueListenable: controller.entitiesNotifier,
        builder: (context, state, child) {
          // Error
          if (state.hasError) {
            if (!state.hasPermission) {
              return const GalleryPermissionView();
            }
          }

          // No data
          if (!state.isLoading && (state.data?.isEmpty ?? true)) {
            return const Center(
              child: Text(
                'No media available',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final entities = state.isLoading ? <AssetEntity>[] : state.data!;

          final itemCount = state.isLoading
              ? 20
              : controller.setting.enableCamera
                  ? entities.length + 1
                  : entities.length;

          return GridView.builder(
            controller: controller.panelController.scrollController,
            padding: const EdgeInsets.all(0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: controller.setting.crossAxisCount ?? 3,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (controller.setting.enableCamera && index == 0) {
                return InkWell(
                  onTap: () => controller.openCamera(context),
                  child: Icon(
                    CupertinoIcons.camera,
                    color: Colors.lightBlue.shade300,
                    size: 26.0,
                  ),
                );
              }

              if (state.isLoading) return const _Loader();

              final ind = controller.setting.enableCamera ? index - 1 : index;

              final entity = entities[ind];

              return _MediaTile(controller: controller, entity: entity);
            },
          );

          //
        },
      ),
    );
  }
}

class _MediaTile extends StatefulWidget {
  ///
  const _MediaTile({
    Key? key,
    required this.entity,
    required this.controller,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final AssetEntity entity;

  @override
  _MediaTileState createState() => _MediaTileState();
}

///
class _MediaTileState extends State<_MediaTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drishyaController = widget.controller;

    return GestureDetector(
      onTap: () {
        widget.controller.select(widget.entity, context);
      },
      child: ColoredBox(
        color: Colors.grey.shade700,
        child: FutureBuilder<Uint8List?>(
          future: widget.entity.thumbDataWithSize(
            400,
            400,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _animation,
                    child: child,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),

                    // Duration
                    if (widget.entity.type == AssetType.video)
                      Positioned(
                        right: 4.0,
                        bottom: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            child: Text(
                              widget.entity.duration.formatedDuration,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Image selection overlay
                    if (!drishyaController.singleSelection)
                      ValueListenableBuilder<GalleryValue>(
                        valueListenable: drishyaController,
                        builder: (context, value, child) {
                          final isSelected =
                              value.selectedEntities.contains(widget.entity);
                          if (!isSelected) return const SizedBox();
                          final index =
                              value.selectedEntities.indexOf(widget.entity);
                          return Container(
                            color: Colors.white54,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 14.0,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    //
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

///
class _Loader extends StatelessWidget {
  ///
  const _Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey.shade700);
  }
}

///
extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString();
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
