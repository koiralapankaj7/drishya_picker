import 'dart:async';

import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/entities/singleton.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

///
class EditorCloseButton extends StatelessWidget {
  ///
  const EditorCloseButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  Future<bool> _onPressed(BuildContext context, {bool pop = true}) async {
    if (!controller.value.hasStickers) {
      if (pop) {
        UIHandler.of(context).pop();
      }
      //  else {
      //   await UIHandler.showStatusBar();
      // }
      return true;
    } else {
      await showDialog<bool>(
        context: context,
        builder: (context) => const _AppDialog(),
      ).then((value) {
        if (value ?? false) {
          controller.clear();
        }
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onPressed(context, pop: false),
      child: EditorBuilder(
        controller: controller,
        builder: (context, value, child) {
          final crossFadeState = value.isEditing || value.hasFocus
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond;
          return AppAnimatedCrossFade(
            firstChild: const SizedBox(),
            secondChild: child!,
            crossFadeState: crossFadeState,
          );
        },
        child: InkWell(
          onTap: () {
            _onPressed(context);
          },
          child: Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
            ),
            child: const Icon(
              CustomIcons.close,
              color: Colors.white,
              size: 16,
            ),
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
        Singleton.textDelegate.no,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
    final unselectItems = TextButton(
      onPressed: () {
        Navigator.of(context).pop(true);
      },
      child: Text(
        Singleton.textDelegate.discard,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );

    return AlertDialog(
      title: Text(
        Singleton.textDelegate.discardChanges,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        Singleton.textDelegate.areYouSureDiscard,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [cancel, unselectItems],
      backgroundColor: Colors.grey.shade900,
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
    );
  }
}
