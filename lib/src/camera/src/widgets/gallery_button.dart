import 'package:flutter/material.dart';

import '../controllers/action_notifier.dart';

///
class GalleryButton extends StatelessWidget {
  ///
  const GalleryButton({
    Key? key,
    required this.action,
  }) : super(key: key);

  ///
  final ActionNotifier action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      width: 54.0,
      height: 54.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: action.hideGalleryPreviewButton
            ? const SizedBox()
            : Container(color: Colors.white),
      ),
    );
  }
}
