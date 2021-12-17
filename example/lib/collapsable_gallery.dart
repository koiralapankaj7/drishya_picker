import 'package:drishya_picker/drishya_picker.dart';
import 'package:example/recent_entities.dart';
import 'package:flutter/material.dart';

import 'grid_view_widget.dart';

///
class CollapsableGallery extends StatefulWidget {
  ///
  const CollapsableGallery({
    Key? key,
  }) : super(key: key);

  @override
  _CollapsableGalleryState createState() => _CollapsableGalleryState();
}

class _CollapsableGalleryState extends State<CollapsableGallery> {
  late final GalleryController controller;
  late final ValueNotifier<List<DrishyaEntity>> notifier;

  @override
  void initState() {
    super.initState();

    notifier = ValueNotifier(<DrishyaEntity>[]);
    controller = GalleryController(
      setting: const GallerySetting(
        albumSubtitle: 'Collapsable',
        enableCamera: true,
        maximum: 10,
        requestType: RequestType.all,
      ),
      panelSetting: const PanelSetting(topMargin: 24.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidableGalleryView(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Slidable Gallery'),
        ),
        body: Column(
          children: [
            // Grid view
            Expanded(
              child: GridViewWidget(
                notifier: notifier,
                controller: controller,
                onAddButtonPressed: () async {
                  final entities = await controller.pick(
                    context,
                    selectedEntities: notifier.value,
                  );
                  notifier.value = entities;
                },
              ),
            ),

            const SizedBox(height: 8.0),

            RecentEntities(controller: controller, notifier: notifier),

            const SizedBox(height: 8.0),

            // Textfield
            Container(
              padding: const EdgeInsets.all(8.0),
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
              child: Row(
                children: [
                  // Textfield
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Test field',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),

                  // Camera field..
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CameraViewField(
                      onCapture: (entity) {
                        notifier.value = [...notifier.value, entity];
                      },
                      child: const Icon(Icons.camera),
                    ),
                  ),

                  // Gallery field
                  ValueListenableBuilder<List<DrishyaEntity>>(
                    valueListenable: notifier,
                    builder: (context, list, child) {
                      return GalleryViewField(
                        selectedEntities: list,
                        onChanged: (entity, isRemoved) {
                          final value = notifier.value.toList();
                          if (isRemoved) {
                            value.remove(entity);
                          } else {
                            value.add(entity);
                          }
                          notifier.value = value;
                        },
                        onSubmitted: (list) {
                          notifier.value = list;
                        },
                        child: child,
                      );
                    },
                    child: const Icon(Icons.photo),
                  ),

                  //
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}
