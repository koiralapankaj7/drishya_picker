import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_builder.dart';
import 'package:flutter/material.dart';

///
class SendButton extends StatelessWidget {
  ///
  const SendButton({
    super.key,
    required this.controller,
  });

  ///
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GalleryBuilder(
        controller: controller,
        builder: (value, child) {
          final crossFadeState = value.selectedEntities.isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond;
          return AppAnimatedCrossFade(
            crossFadeState: crossFadeState,
            firstChild: const SizedBox(),
            secondChild: Stack(
              clipBehavior: Clip.none,
              children: [
                child!,
                Positioned(
                  top: -6,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: scheme.secondary,
                    radius: 12,
                    child: Text(
                      '${value.selectedEntities.length}',
                      style: theme.textTheme.caption?.copyWith(
                        color: scheme.onSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(controller.value.selectedEntities);
          },
          child: Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.onPrimary,
            ),
            child: Icon(
              CustomIcons.send,
              color: scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
