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
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Media
                      Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),

                      // For video duration
                      // Duration
                      if (entity.type == AssetType.video)
                        Positioned(
                          right: 4.0,
                          bottom: 4.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              color: Colors.black.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              child: Text(
                                entity.duration.formatedDuration,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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

///
extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString();
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
