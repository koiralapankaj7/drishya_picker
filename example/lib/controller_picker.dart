import 'package:flutter/material.dart';
import 'package:drishya_picker/drishya_picker.dart';

import 'grid_view_widget.dart';

///
class ControllerPicker extends StatefulWidget {
  @override
  _ControllerPickerState createState() => _ControllerPickerState();
}

class _ControllerPickerState extends State<ControllerPicker> {
  final notifier = ValueNotifier(<AssetEntity>[]);
  final controller = DrishyaController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: const Text('Pick using controller'),
      ),
      body: DrishyaPicker(
        controller: controller,
        // requestType: RequestType.image,
        child: Column(
          children: [
            // Grid view
            Expanded(
              child: Container(
                color: Colors.grey.shade200,
                child: GridViewWidget(notifier: notifier),
              ),
            ),

            // Textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Test field',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  CircleAvatar(
                    backgroundColor: Colors.cyan,
                    minRadius: 10.0,
                    child: Builder(builder: (ctx) {
                      return IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final data = await controller.pickFromGallery(
                            ctx,
                            setting: DrishyaSetting(
                              selectedItems: notifier.value,
                              maximum: 10,
                              albumSubtitle: 'image only',
                              source: DrishyaSource.gallery,
                            ),
                          );
                          notifier.value = data ?? [];
                        },
                      );
                    }),
                  ),
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
