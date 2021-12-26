import 'package:drishya_picker/drishya_picker.dart';
import 'package:example/recent_entities.dart';
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
  late final ValueNotifier<List<DrishyaEntity>> notifier;

  @override
  void initState() {
    super.initState();
    controller = GalleryController();
    notifier = ValueNotifier(<DrishyaEntity>[]);
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
      appBar: AppBar(
        title: const Text('Fullscreen Gallery'),
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
                  setting: const GallerySetting(
                    maximum: 1,
                    albumSubtitle: 'All',
                    requestType: RequestType.all,
                  ),
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
                    onCapture: (entity) =>
                        notifier.value = [...notifier.value, entity],
                    child: const Icon(Icons.camera),
                  ),
                ),

                // Gallery field
                ValueListenableBuilder<List<DrishyaEntity>>(
                  valueListenable: notifier,
                  builder: (context, list, child) {
                    return GalleryViewField(
                      selectedEntities: list,
                      setting: const GallerySetting(
                        maximum: 10,
                        albumSubtitle: 'Image only',
                        requestType: RequestType.image,
                      ),
                      onChanged: (entity, remove) {
                        final value = notifier.value.toList();
                        remove ? value.remove(entity) : value.add(entity);
                        notifier.value = value;
                      },
                      onSubmitted: (list) => notifier.value = list,
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
