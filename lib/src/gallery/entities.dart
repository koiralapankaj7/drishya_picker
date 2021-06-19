import 'package:photo_manager/photo_manager.dart';

///
/// Source of drishya
/// [camera], [gallery]
///
enum DrishyaSource {
  ///
  camera,

  ///
  gallery,
}

///
/// Setting for drishya picker
///
class DrishyaSetting {
  ///
  const DrishyaSetting({
    this.source = DrishyaSource.gallery,
    this.requestType = RequestType.all,
    this.selectedItems = const <AssetEntity>[],
    this.maximum = 20,
    this.albumSubtitle = 'Select Media',
    this.enableCamera = true,
  });

  ///
  /// Source of assets picker
  /// Default [DrishyaSource.gallery]
  ///
  final DrishyaSource source;

  ///
  /// Type of media e.g, image, video, audio, other
  /// Default is [RequestType.all]
  ///
  final RequestType requestType;

  ///
  /// Previously selected media which will be pre selected
  /// Ignored if [source] is [DrishyaSource.camera]
  ///
  final List<AssetEntity> selectedItems;

  ///
  /// Total medai allowed to select. Default is 20
  /// Ignored if [source] is [DrishyaSource.camera]
  ///
  final int maximum;

  ///
  /// String displayed below alnum name. Default : 'Select media'
  /// Ignored if [source] is [DrishyaSource.camera]
  ///
  final String albumSubtitle;

  ///
  /// Set false to hide camera from gallery view
  final bool enableCamera;
}

///
class DrishyaValue {
  ///
  const DrishyaValue({
    this.entities = const <AssetEntity>[],
    this.previousSelection = true,
  });

  ///
  final List<AssetEntity> entities;

  ///
  final bool previousSelection;

  ///
  DrishyaValue copyWith({
    List<AssetEntity>? entities,
    bool? previousSelection,
  }) =>
      DrishyaValue(
        entities: entities ?? this.entities,
        previousSelection: previousSelection ?? this.previousSelection,
      );

  @override
  String toString() => 'LENGTH  :  ${entities.length} \nLIST  :  $entities';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is DrishyaValue) {
      if (entities.length != other.entities.length) return false;

      var isIdentical = true;
      for (var i = 0; i < entities.length; i++) {
        if (!isIdentical) return false;
        isIdentical = other.entities[i].id == entities[i].id;
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => entities.hashCode;

  // hashValues(
  //       text.hashCode,
  //       selection.hashCode,
  //       composing.hashCode,
  //     );
}
