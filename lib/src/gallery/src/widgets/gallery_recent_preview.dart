import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

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
  final AssetEntity entity;

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
          child: FutureBuilder<Uint8List?>(
            future: entity.thumbDataWithSize(
              width?.toInt() ?? 100,
              height?.toInt() ?? 100,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.data == null) {
                return child ?? const SizedBox();
              }
              return builder?.call(snapshot.data!) ??
                  child ??
                  Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  );
            },
          ),
        ),
      ),
    );
  }
}
