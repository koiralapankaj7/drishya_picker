import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class MediaTile extends StatelessWidget {
  ///
  const MediaTile({
    Key? key,
    required this.entity,
  }) : super(key: key);

  ///
  final DrishyaEntity entity;

  @override
  Widget build(BuildContext context) {
    Widget? child;

    if (entity.type == AssetType.image || entity.type == AssetType.video) {
      child = Image.memory(
        entity.thumbBytes,
        fit: BoxFit.cover,
      );
    }

    if (entity.type == AssetType.audio) {
      child = const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.audiotrack,
            color: Colors.white,
          ),
        ),
      );
    }

    if (entity.type == AssetType.video || entity.type == AssetType.audio) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          child ?? const SizedBox(),
          Positioned(
            right: 4.0,
            bottom: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                child: Text(
                  entity.videoDuration.inSeconds.formatedDuration,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return child ?? const SizedBox();
  }
}

extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString();
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
