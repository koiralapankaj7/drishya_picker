import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controllers/action_notifier.dart';

///
class CameraCloseButton extends StatelessWidget {
  ///
  const CameraCloseButton({
    Key? key,
    required this.action,
  }) : super(key: key);

  ///
  final ActionNotifier action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: Navigator.of(context).pop,
      child: Container(
        height: 36.0,
        width: 36.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
        ),
        child: const Icon(
          CustomIcons.close,
          color: Colors.white,
          size: 16.0,
        ),
      ),
    );
  }
}
