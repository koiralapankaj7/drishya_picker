import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class GridViewWidget extends StatelessWidget {
  ///
  const GridViewWidget({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  ///
  final ValueNotifier<List<DrishyaEntity>> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DrishyaEntity>>(
      valueListenable: notifier,
      builder: (context, list, child) {
        if (list.isEmpty) {
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
          itemCount: list.length,
          itemBuilder: (context, index) {
            final entity = list[index];
            return EntityThumbnail(entity: entity);
          },
        );
      },
    );
  }
}

///