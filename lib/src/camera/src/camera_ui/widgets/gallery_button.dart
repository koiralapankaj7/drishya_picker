import 'package:flutter/material.dart';

import '../../entities/camera_type.dart';
import '../builders/camera_type_builder.dart';

///
class GalleryButton extends StatelessWidget {
  ///
  const GalleryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      width: 54.0,
      height: 54.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CameraTypeBuilder(
          builder: (action, type, child) {
            if (type == CameraType.text) return const SizedBox();
            return child!;
          },
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}
