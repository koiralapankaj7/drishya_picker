import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/drishya_repository.dart';
import 'package:drishya_picker/src/gallery/media_tile.dart';
import 'package:drishya_picker/src/gallery/permission_view.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class GalleryGrid extends StatelessWidget {
  ///
  const GalleryGrid({
    Key? key,
    required this.controller,
    required this.panelSetting,
    required this.entitiesNotifier,
    required this.onCameraPressed,
    required this.onMediaSelect,
  }) : super(key: key);

  ///
  final DrishyaController controller;

  ///
  final PanelSetting panelSetting;

  ///
  final ValueNotifier<EntitiesType> entitiesNotifier;

  ///
  final void Function(BuildContext context) onCameraPressed;

  ///
  final void Function(AssetEntity entity, BuildContext context) onMediaSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: panelSetting.foregroundColor,
      child: ValueListenableBuilder<EntitiesType>(
        valueListenable: entitiesNotifier,
        builder: (context, state, child) {
          // Error
          if (state.hasError) {
            if (!state.hasPermission) {
              return const PermissionRequest();
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 1.0,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (controller.setting.enableCamera && index == 0) {
                return InkWell(
                  onTap: () {
                    onCameraPressed(context);
                  },
                  child: Icon(
                    CupertinoIcons.camera,
                    color: Colors.lightBlue.shade300,
                    size: 26.0,
                  ),
                );
              }

              if (state.isLoading) return const Loader();

              final ind = controller.setting.enableCamera ? index - 1 : index;

              final entity = entities[ind];

              return MediaTile(
                drishyaController: controller,
                entity: entity,
                onSelect: () {
                  onMediaSelect(entity, context);
                },
              );
            },
          );

          //
        },
      ),
    );
  }
}
