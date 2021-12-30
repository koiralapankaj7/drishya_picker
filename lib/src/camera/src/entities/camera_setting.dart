import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

///
@immutable
class CameraSetting {
  ///
  const CameraSetting({
    this.resolutionPreset = ResolutionPreset.high,
    this.imageFormatGroup = ImageFormatGroup.jpeg,
    this.videoDuration = const Duration(seconds: 10),
    this.editAfterCapture = true,
    this.enableGallery = true,
  });

  /// Image resolution. Default value is [ResolutionPreset.high].
  final ResolutionPreset resolutionPreset;

  /// Image format group. Default value is [ImageFormatGroup.jpeg]
  final ImageFormatGroup imageFormatGroup;

  /// Video duration. Default value is 10 seconds
  final Duration videoDuration;

  /// if true, photo editor will be open after capture
  final bool editAfterCapture;

  /// if true, gallery will be enabled
  final bool enableGallery;

  ///
  CameraSetting copyWith({
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
    Duration? videoDuration,
    bool? editAfterCapture,
    bool? enableGallery,
  }) {
    return CameraSetting(
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      imageFormatGroup: imageFormatGroup ?? this.imageFormatGroup,
      videoDuration: videoDuration ?? this.videoDuration,
      editAfterCapture: editAfterCapture ?? this.editAfterCapture,
      enableGallery: enableGallery ?? this.enableGallery,
    );
  }

  @override
  String toString() {
    return '''
    CameraSetting(
      resolutionPreset: $resolutionPreset, 
      imageFormatGroup: $imageFormatGroup, 
      videoDuration: $videoDuration, 
      editAfterCapture: $editAfterCapture, 
      enableGallery: $enableGallery
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CameraSetting &&
        other.resolutionPreset == resolutionPreset &&
        other.imageFormatGroup == imageFormatGroup &&
        other.videoDuration == videoDuration &&
        other.editAfterCapture == editAfterCapture &&
        other.enableGallery == enableGallery;
  }

  @override
  int get hashCode {
    return resolutionPreset.hashCode ^
        imageFormatGroup.hashCode ^
        videoDuration.hashCode ^
        editAfterCapture.hashCode ^
        enableGallery.hashCode;
  }
}
