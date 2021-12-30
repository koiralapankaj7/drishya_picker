import 'package:drishya_picker/drishya_picker.dart';
import 'package:example/fullscreen_gallery.dart';
import 'package:flutter/material.dart';

///
class GridViewWidget extends StatelessWidget {
  ///
  const GridViewWidget({
    Key? key,
    required this.controller,
    required this.setting,
    required this.notifier,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final GallerySetting setting;

  ///
  final ValueNotifier<Data> notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ValueListenableBuilder<Data>(
        valueListenable: notifier,
        builder: (context, data, child) {
          if (data.entities.isEmpty) {
            return ValueListenableBuilder<PanelValue>(
              valueListenable: controller.panelController,
              builder: (context, value, child) {
                if (value.state == PanelState.close) {
                  return child!;
                }
                return const SizedBox();
              },
              child: Center(
                child: InkWell(
                  onTap: () async {
                    final entities = await controller.pick(
                      context,
                      setting: setting.copyWith(
                        maximumCount: notifier.value.maxLimit,
                        albumSubtitle: 'All',
                        requestType: notifier.value.requestType,
                        selectedEntities: notifier.value.entities,
                      ),
                    );
                    notifier.value =
                        notifier.value.copyWith(entities: entities);
                  },
                  child: const CircleAvatar(
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(4.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 1.0,
            ),
            itemCount: data.entities.length,
            itemBuilder: (context, index) {
              final entity = data.entities[index];
              return EntityThumbnail(entity: entity);
            },
          );
        },
      ),
    );
  }
}

///
