import 'package:flutter/material.dart';
import 'package:drishya_picker/drishya_picker.dart';

import 'grid_view_widget.dart';

///
class Picker2 extends StatefulWidget {
  @override
  _Picker2State createState() => _Picker2State();
}

class _Picker2State extends State<Picker2> {
  final notifier = ValueNotifier<List<AssetEntity>?>(<AssetEntity>[]);

  @override
  Widget build(BuildContext context) {
    return DrishyaPicker(
      requestType: RequestType.common,
      topMargin: MediaQuery.of(context).padding.top,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pick using picker view'),
        ),
        body: Column(
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
                  ValueListenableBuilder<List<AssetEntity>?>(
                    valueListenable: notifier,
                    builder: (context, list, child) {
                      return MediaPicker(
                        setting: DrishyaSetting(
                          selected: list,
                          maximum: 5,
                          albumSubtitle: 'common',
                        ),
                        onChanged: (entity, isRemoved) {
                          final value = notifier.value?.toList() ?? [];
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
                    child: const CircleAvatar(
                      backgroundColor: Colors.cyan,
                      minRadius: 24.0,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
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
