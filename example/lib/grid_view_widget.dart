import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:drishya_picker/drishya_picker.dart';

///
class GridViewWidget extends StatelessWidget {
  ///
  const GridViewWidget({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  ///
  final ValueNotifier<List<AssetEntity>?> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AssetEntity>?>(
      valueListenable: notifier,
      builder: (context, list, child) {
        if (list?.isEmpty ?? true) {
          return const Center(
            child: Text('No data'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(4.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1.0,
            mainAxisSpacing: 1.0,
          ),
          itemCount: list!.length,
          itemBuilder: (context, index) {
            final entity = list[index];
            return FutureBuilder<Uint8List?>(
              future: entity.thumbDataWithSize(400, 400),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
                return const SizedBox();
              },
            );
          },
        );
      },
    );
  }
}
