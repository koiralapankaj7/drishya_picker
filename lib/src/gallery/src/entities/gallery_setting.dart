import 'package:photo_manager/photo_manager.dart';

///
/// Setting for drishya picker
///
class GallerySetting {
  ///
  const GallerySetting({
    this.requestType = RequestType.all,
    this.maximum = 20,
    this.albumSubtitle = 'Select Media',
    this.enableCamera = true,
    this.crossAxisCount,
  });

  ///
  /// Type of media e.g, image, video, audio, other
  /// Default is [RequestType.all]
  ///
  final RequestType requestType;

  ///
  /// Total medai allowed to select. Default is 20
  ///
  final int maximum;

  ///
  /// String displayed below alnum name. Default : 'Select media'
  ///
  final String albumSubtitle;

  ///
  /// Set false to hide camera from gallery view
  final bool enableCamera;

  ///
  /// Gallery cross axis count. Default is 3
  ///
  final int? crossAxisCount;
}
