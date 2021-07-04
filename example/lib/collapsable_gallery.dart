import 'package:drishya_picker/drishya_picker.dart';
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
  final notifier = ValueNotifier<List<AssetEntity>>(<AssetEntity>[]);
  late final GalleryController controller;

  @override
  void initState() {
    super.initState();
    controller = GalleryController(
      gallerySetting: const GallerySetting(
        albumSubtitle: 'Collapsable',
        enableCamera: false,
        maximum: 10,
        requestType: RequestType.all,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(
        title: const Text('Pick using picker view'),
      ),
      body: GalleryViewWrapper(
        controller: controller,
        child: Column(
          children: [
            // Grid view
            Expanded(child: GridViewWidget(notifier: notifier)),

            //
            Builder(builder: (context) {
              return TextButton(
                onPressed: () async {
                  final entities = await controller.pick(
                    context,
                    selectedEntities: notifier.value,
                  );
                  notifier.value = entities ?? [];
                },
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text('Use Controller'),
              );
            }),

            // Textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Textfield
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Test field',
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
                  ValueListenableBuilder<List<AssetEntity>?>(
                    valueListenable: notifier,
                    builder: (context, list, child) {
                      return GalleryViewField(
                        selectedEntities: list ?? [],
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
