import 'package:drishya_picker/drishya_picker.dart';

///
/// Setting for drishya picker
class GallerySetting {
  ///
  /// Gallery setting
  const GallerySetting({
    this.requestType = RequestType.all,
    this.maximum = 20,
    this.albumSubtitle = 'Select Media',
    this.albumTitle = 'All Photos',
    this.enableCamera = true,
    this.crossAxisCount,
    this.panelSetting,
    this.editorSetting,
    this.cameraSetting,
    this.cameraTextEditorSetting,
    this.cameraPhotoEditorSetting,
    this.showCameraInsideGrid = true,
    this.showMultiSelectionButton = false,
  });

  ///
  /// Type of media e.g, image, video, audio, other
  /// Default is [RequestType.all]
  final RequestType requestType;

  ///
  /// Total media allowed to select. Default is 20
  final int maximum;

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
  /// If true, camera button will be shown inside grid view, else
  /// it will be shown as floating button,
  ///
  /// Default value is true.
  final bool showCameraInsideGrid;

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
  /// If true, this flag will be used to determine
  /// single-selection/multi-selection
  final bool showMultiSelectionButton;

  ///
  /// Helper function to copy its properties
  GallerySetting copyWith({
    RequestType? requestType,
    int? maximum,
    String? albumSubtitle,
    String? albumTitle,
    bool? enableCamera,
    bool? showCameraInsideGrid,
    int? crossAxisCount,
    PanelSetting? panelSetting,
    EditorSetting? editorSetting,
    CameraSetting? cameraSetting,
    EditorSetting? cameraTextEditorSetting,
    EditorSetting? cameraPhotoEditorSetting,
    bool? showMultiSelectionButton,
  }) {
    return GallerySetting(
      requestType: requestType ?? this.requestType,
      maximum: maximum ?? this.maximum,
      albumSubtitle: albumSubtitle ?? this.albumSubtitle,
      albumTitle: albumTitle ?? this.albumTitle,
      enableCamera: enableCamera ?? this.enableCamera,
      showCameraInsideGrid: showCameraInsideGrid ?? this.showCameraInsideGrid,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      panelSetting: panelSetting ?? this.panelSetting,
      editorSetting: editorSetting ?? this.editorSetting,
      cameraSetting: cameraSetting ?? this.cameraSetting,
      cameraTextEditorSetting:
          cameraTextEditorSetting ?? this.cameraTextEditorSetting,
      cameraPhotoEditorSetting:
          cameraPhotoEditorSetting ?? this.cameraPhotoEditorSetting,
      showMultiSelectionButton:
          showMultiSelectionButton ?? this.showMultiSelectionButton,
    );
  }
}
