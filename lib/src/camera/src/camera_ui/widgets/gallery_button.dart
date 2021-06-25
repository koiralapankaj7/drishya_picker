import 'package:flutter/material.dart';

import '../builders/action_detector.dart';

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
        child: ActionBuilder(
          builder: (action, value, child) {
            if (action.hideGalleryPreviewButton) {
              return const SizedBox();
            }
            return child!;
          },
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}
