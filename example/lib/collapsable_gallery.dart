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
  final controller = DrishyaController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(
        title: const Text('Pick using picker view'),
      ),
      body: DrishyaPicker(
        controller: controller,
        child: Column(
          children: [
            // Grid view
            Expanded(child: GridViewWidget(notifier: notifier)),

            //
            Builder(builder: (context) {
              return TextButton(
                onPressed: () async {
                  final entities = await controller.pickFromGallery(
                    context,
                    setting: DrishyaSetting(
                      selectedItems: notifier.value,
                      maximum: 10,
                      albumSubtitle: 'Image only',
                      requestType: RequestType.image,
                    ),
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
                    child: CameraPicker(
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
                      return GalleryPicker(
                        setting: DrishyaSetting(
                          selectedItems: list ?? [],
                          maximum: 5,
                          albumSubtitle: 'common',
                        ),
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
