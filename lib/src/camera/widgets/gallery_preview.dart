import 'package:flutter/material.dart';

import 'camera_type.dart';

///
class GalleryPreview extends StatelessWidget {
  ///
  const GalleryPreview({
    Key? key,
    required this.cameraTypeNotifier,
  }) : super(key: key);

  ///
  final ValueNotifier<CameraType> cameraTypeNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      width: 54.0,
      height: 54.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CameraTypeBuilder(
          notifier: cameraTypeNotifier,
          builder: (context, type, child) {
            if (type == CameraType.text) return const SizedBox();
            return child!;
          },
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}
