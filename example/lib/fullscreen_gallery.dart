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
  late final GalleryController controller;
  late final ValueNotifier<List<AssetEntity>> notifier;

  @override
  void initState() {
    super.initState();
    const setting = GallerySetting(
      maximum: 1,
      albumSubtitle: 'All',
      requestType: RequestType.all,
    );
    controller = GalleryController(gallerySetting: setting);
    notifier = ValueNotifier(<AssetEntity>[]);
  }

  @override
  void dispose() {
    super.dispose();
    notifier.dispose();
    controller.dispose();
  }

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
                      gallerySetting: const GallerySetting(
                        maximum: 10,
                        albumSubtitle: 'Image only',
                        requestType: RequestType.image,
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
