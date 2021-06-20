import 'package:flutter/material.dart';

import '../custom_icons.dart';

///
class CloseIconButton extends StatelessWidget {
  ///
  const CloseIconButton({Key? key}) : super(key: key);

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
