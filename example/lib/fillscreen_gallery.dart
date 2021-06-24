import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

import 'grid_view_widget.dart';

///
class FullscreenGallery extends StatefulWidget {
  ///
  const FullscreenGallery({
    Key? key,
  }) : super(key: key);

  @override
  _FullscreenGalleryState createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  final notifier = ValueNotifier<List<AssetEntity>>(<AssetEntity>[]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: const Text('Fullscreen gallery picker'),
      ),
      body: Column(
        children: [
          // Grid view
          Expanded(child: GridViewWidget(notifier: notifier)),

          TextButton(
            onPressed: () async {
              final entities = await DrishyaController().pickFromGallery(
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
          ),

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
                  child: CameraPickerField(
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
                    return GalleryPickerField(
                      setting: DrishyaSetting(
                        selectedItems: list ?? [],
                        maximum: 1,
                        albumSubtitle: 'Common',
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
    );
  }
}
