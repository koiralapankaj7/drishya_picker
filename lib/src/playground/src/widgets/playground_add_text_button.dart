import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';

///
class PlaygroundAddTextButton extends StatelessWidget {
  ///
  const PlaygroundAddTextButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.updateValue(hasFocus: true);
      },
      child: const Text(
        'Tap to type...',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
