import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import 'playground_builder.dart';

///
class PlaygroundCloseButton extends StatelessWidget {
  ///
  const PlaygroundCloseButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  void _onPressed(BuildContext context) {
    if (controller.isPlaygroundEmpty) {
      Navigator.of(context).pop();
    } else {
      showDialog<bool>(
        context: context,
        builder: (context) => const _AppDialog(),
      ).then((value) {
        if (value ?? false) {
          controller.clearPlayground();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlaygroundBuilder(
      controller: controller,
      builder: (context, value, child) {
        if (value.isEditing) return const SizedBox();
        return child!;
      },
      child: InkWell(
        onTap: () {
          _onPressed(context);
        },
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
      ),
    );
  }
}

class _AppDialog extends StatelessWidget {
  const _AppDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cancel = TextButton(
      onPressed: Navigator.of(context).pop,
      child: Text(
        'NO',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.lightBlue,
            ),
      ),
    );
    final unselectItems = TextButton(
      onPressed: () {
        Navigator.of(context).pop(true);
      },
      child: Text(
        'DISCARD',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.blue,
            ),
      ),
    );

    return AlertDialog(
      title: Text(
        'Discard changes?',
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Colors.white70,
            ),
      ),
      content: Text(
        'Are you sure you want to discard your changes?',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
      actions: [cancel, unselectItems],
      backgroundColor: Colors.grey.shade900,
      actionsPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(16.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
    );
  }
}
