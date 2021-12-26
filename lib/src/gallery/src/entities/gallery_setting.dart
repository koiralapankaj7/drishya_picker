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
    this.enableCamera = true,
    this.crossAxisCount,
    this.panelSetting,
    this.editorSetting,
    this.cameraSetting,
    this.cameraTextEditorSetting,
    this.cameraPhotoEditorSetting,
  });

  ///
  /// Type of media e.g, image, video, audio, other
  /// Default is [RequestType.all]
  final RequestType requestType;

  ///
  /// Total media allowed to select. Default is 20
  final int maximum;

  ///
  /// String displayed below album name. Default : 'Select media'
  ///
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
}
