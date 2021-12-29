import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

/// Camera controller value
@immutable
class CamValue {
  ///
  const CamValue({
    this.cameraDescription,
    this.cameras = const [],
    this.cameraType = CameraType.normal,
    this.enableAudio = true,
    this.flashMode = FlashMode.off,
    this.isTakingPicture = false,
    this.isRecordingVideo = false,
    this.isRecordingPaused = false,
    this.isPlaygroundActive = false,
    this.error,
  });

  /// Current active camera description e,g. Front camera or back camera
  final CameraDescription? cameraDescription;

  /// Available camera description list
  final List<CameraDescription> cameras;

  /// Type of the active camera
  final CameraType cameraType;

  /// Audio will be enabled if value is true
  final bool enableAudio;

  /// Camera flash mode
  final FlashMode flashMode;

  /// Return true if camera is taking picture
  final bool isTakingPicture;

  /// Return true if camera is recording video
  final bool isRecordingVideo;

  /// Return true if video recording is in pause state
  final bool isRecordingPaused;

  /// Return true if playground is active
  final bool isPlaygroundActive;

  /// Any error that is related to camera
  final CameraException? error;

  ///
  CamValue copyWith({
    CameraDescription? cameraDescription,
    List<CameraDescription>? cameras,
    CameraType? cameraType,
    bool? enableAudio,
    FlashMode? flashMode,
    bool? isTakingPicture,
    bool? isRecordingVideo,
    bool? isRecordingPaused,
    bool? isPlaygroundActive,
    CameraException? error,
  }) {
    return CamValue(
      cameraDescription: cameraDescription ?? this.cameraDescription,
      cameras: cameras ?? this.cameras,
      cameraType: cameraType ?? this.cameraType,
      enableAudio: enableAudio ?? this.enableAudio,
      flashMode: flashMode ?? this.flashMode,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      isRecordingPaused: isRecordingPaused ?? this.isRecordingPaused,
      isPlaygroundActive: isPlaygroundActive ?? this.isPlaygroundActive,
      error: error ?? this.error,
    );
  }

  //========================== GETTERS ==================================

  ///
  /// Current lense direction
  ///
  CameraLensDirection get lensDirection =>
      cameraDescription?.lensDirection ?? CameraLensDirection.back;

  ///
  /// Opposite lense direction of current [lensDirection]
  ///
  CameraLensDirection get oppositeLensDirection =>
      lensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

  ///
  /// Hide camera close button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraCloseButton =>
      cameraType == CameraType.text || isRecordingVideo;

  ///
  /// Hide camera flash button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Camera lense direction is front
  /// 3. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraFlashButton =>
      cameraType == CameraType.text ||
      lensDirection == CameraLensDirection.front ||
      isRecordingVideo;

  ///
  /// Hide camera shutter button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  ///
  bool get hideCameraShutterButton => cameraType == CameraType.text;

  ///
  /// Hide camera footer if :-
  ///
  /// 1. Video recoring is active [isRecordingVideo]
  /// 2. When [CameraType.text] playground is in editing mode
  ///
  bool get hideCameraFooter => isRecordingVideo || isPlaygroundActive;

  ///
  /// Hide camera gallery  button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraGalleryButton =>
      cameraType == CameraType.text || isRecordingVideo;

  ///
  /// Hide camera rotation button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraRotationButton =>
      cameraType == CameraType.text || isRecordingVideo;

  @override
  String toString() {
    return '''
    CamValue(
      cameraDescription: $cameraDescription, 
      cameras: $cameras, 
      cameraType: $cameraType, 
      enableAudio: $enableAudio, 
      flashMode: $flashMode, 
      isTakingPicture: $isTakingPicture, 
      isRecordingVideo: $isRecordingVideo, 
      isRecordingPaused: $isRecordingPaused, 
      isPlaygroundActive: $isPlaygroundActive, 
      error: $error
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is CamValue &&
        other.cameraDescription == cameraDescription &&
        listEquals(other.cameras, cameras) &&
        other.cameraType == cameraType &&
        other.enableAudio == enableAudio &&
        other.flashMode == flashMode &&
        other.isTakingPicture == isTakingPicture &&
        other.isRecordingVideo == isRecordingVideo &&
        other.isRecordingPaused == isRecordingPaused &&
        other.isPlaygroundActive == isPlaygroundActive &&
        other.error == error;
  }

  @override
  int get hashCode {
    return cameraDescription.hashCode ^
        cameras.hashCode ^
        cameraType.hashCode ^
        enableAudio.hashCode ^
        flashMode.hashCode ^
        isTakingPicture.hashCode ^
        isRecordingVideo.hashCode ^
        isRecordingPaused.hashCode ^
        isPlaygroundActive.hashCode ^
        error.hashCode;
  }
}
