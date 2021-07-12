import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../drishya_entity.dart';

///
class GalleryRecentPreview extends StatelessWidget {
  ///
  const GalleryRecentPreview({
    Key? key,
    required this.entity,
    this.builder,
    this.child,
    this.height,
    this.width,
  }) : super(key: key);

  ///
  final Widget Function(Uint8List bytes)? builder;

  ///
  final Widget? child;

  ///
  final DrishyaEntity entity;

  ///
  final double? height;

  ///
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        height: height ?? 54.0,
        width: width ?? 54.0,
        child: ColoredBox(
          color: Colors.white,
          child: builder?.call(entity.bytes) ??
              child ??
              Image.memory(
                entity.bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
        ),
      ),
    );
  }
}
