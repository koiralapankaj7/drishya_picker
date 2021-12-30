import 'package:collection/collection.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

/// Available multiselection mode for gallery
enum SelectionMode {
  /// maximumCount provided in [GallerySetting] will be use to determine
  /// selection mode.
  countBased,

  /// Multiselection toogler widget will be used to determine selection mode.
  /// maximumCount provided in [GallerySetting] will be preserved
  actionBased,
}

///
/// Setting for drishya picker
@immutable
class GallerySetting {
  ///
  /// Gallery setting
  const GallerySetting({
    this.selectedEntities = const [],
    this.requestType = RequestType.all,
    this.maximumCount = 50,
    this.selectionMode = SelectionMode.countBased,
    this.albumTitle = 'All Photos',
    this.albumSubtitle = 'Select Media',
    this.enableCamera = true,
    this.crossAxisCount,
    this.panelSetting,
    this.editorSetting,
    this.cameraSetting,
    this.cameraTextEditorSetting,
    this.cameraPhotoEditorSetting,
  });

  ///
  /// Previously selected entities
  final List<DrishyaEntity> selectedEntities;

  ///
  /// Type of media e.g, image, video, audio, other
  /// Default is [RequestType.all]
  final RequestType requestType;

  ///
  /// Total media allowed to select. Default is 50
  final int maximumCount;

  ///
  /// Multiselection mode, default is [SelectionMode.countBased]
  final SelectionMode selectionMode;

  ///
  /// Album name for all photos, default is set to "All Photos"
  final String albumTitle;

  ///
  /// String displayed below album name. Default : 'Select media'
  final String albumSubtitle;

  ///
  /// Set false to hide camera from gallery view
  final bool enableCamera;

  ///
  /// Gallery grid cross axis count. Default is 3
  final int? crossAxisCount;

  ///
  /// Gallery slidable panel setting
  final PanelSetting? panelSetting;

  ///
  /// Gallery photo editor setting, if null default setting will be used
  final EditorSetting? editorSetting;

  ///
  /// Camera setting
  final CameraSetting? cameraSetting;

  ///
  /// Camera text editor setting, if null [editorSetting] will be used
  final EditorSetting? cameraTextEditorSetting;

  ///
  /// Camera photo editor setting, if null [editorSetting] will be used
  final EditorSetting? cameraPhotoEditorSetting;

  ///
  /// Helper function to copy its properties
  GallerySetting copyWith({
    List<DrishyaEntity>? selectedEntities,
    RequestType? requestType,
    int? maximumCount,
    SelectionMode? selectionMode,
    String? albumTitle,
    String? albumSubtitle,
    bool? enableCamera,
    int? crossAxisCount,
    PanelSetting? panelSetting,
    EditorSetting? editorSetting,
    CameraSetting? cameraSetting,
    EditorSetting? cameraTextEditorSetting,
    EditorSetting? cameraPhotoEditorSetting,
  }) {
    return GallerySetting(
      selectedEntities: selectedEntities ?? this.selectedEntities,
      requestType: requestType ?? this.requestType,
      maximumCount: maximumCount ?? this.maximumCount,
      selectionMode: selectionMode ?? this.selectionMode,
      albumTitle: albumTitle ?? this.albumTitle,
      albumSubtitle: albumSubtitle ?? this.albumSubtitle,
      enableCamera: enableCamera ?? this.enableCamera,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      panelSetting: panelSetting ?? this.panelSetting,
      editorSetting: editorSetting ?? this.editorSetting,
      cameraSetting: cameraSetting ?? this.cameraSetting,
      cameraTextEditorSetting:
          cameraTextEditorSetting ?? this.cameraTextEditorSetting,
      cameraPhotoEditorSetting:
          cameraPhotoEditorSetting ?? this.cameraPhotoEditorSetting,
    );
  }

  @override
  String toString() {
    return '''
    GallerySetting(
      selectedEntities: $selectedEntities, 
      requestType: $requestType, 
      maximumCount: $maximumCount, 
      selectionMode: $selectionMode, 
      albumTitle: $albumTitle, 
      albumSubtitle: $albumSubtitle, 
      enableCamera: $enableCamera, 
      crossAxisCount: $crossAxisCount, 
      panelSetting: $panelSetting, 
      editorSetting: $editorSetting, 
      cameraSetting: $cameraSetting, 
      cameraTextEditorSetting: $cameraTextEditorSetting, 
      cameraPhotoEditorSetting: $cameraPhotoEditorSetting
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is GallerySetting &&
        listEquals(other.selectedEntities, selectedEntities) &&
        other.requestType == requestType &&
        other.maximumCount == maximumCount &&
        other.selectionMode == selectionMode &&
        other.albumTitle == albumTitle &&
        other.albumSubtitle == albumSubtitle &&
        other.enableCamera == enableCamera &&
        other.crossAxisCount == crossAxisCount &&
        other.panelSetting == panelSetting &&
        other.editorSetting == editorSetting &&
        other.cameraSetting == cameraSetting &&
        other.cameraTextEditorSetting == cameraTextEditorSetting &&
        other.cameraPhotoEditorSetting == cameraPhotoEditorSetting;
  }

  @override
  int get hashCode {
    return selectedEntities.hashCode ^
        requestType.hashCode ^
        maximumCount.hashCode ^
        selectionMode.hashCode ^
        albumTitle.hashCode ^
        albumSubtitle.hashCode ^
        enableCamera.hashCode ^
        crossAxisCount.hashCode ^
        panelSetting.hashCode ^
        editorSetting.hashCode ^
        cameraSetting.hashCode ^
        cameraTextEditorSetting.hashCode ^
        cameraPhotoEditorSetting.hashCode;
  }
}
