import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

///
/// Source of drishya
/// [camera], [gallery]
///
enum DrishyaSource { camera, gallery }

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
    this.fullScreenMode = false,
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
  /// Gallery view screen mode.
  /// Gallery view will be collapsable by default.
  /// Set [fullScreenMode] true for full screen mode
  final bool fullScreenMode;
}

///
/// Settings for gallery panel
///
class PanelSetting {
  ///
  const PanelSetting({
    this.panelHeaderMaxHeight,
    this.panelHeaderMinHeight,
    this.panelHeaderBackground,
    this.panelMinHeight,
    this.panelMaxHeight,
    this.panelBackground,
    this.snapingPoint,
    this.background,
    this.topMargin,
  }) : assert(
          snapingPoint == null || (snapingPoint >= 0.0 && snapingPoint <= 1.0),
          '[snapingPoint] value must be between 1.0 and 0.0',
        );

  /// Panel maximum height
  ///
  /// mediaQuery = MediaQuery.of(context)
  /// Default: mediaQuery.size.height -  mediaQuery.padding.top
  final double? panelMaxHeight;

  /// Panel minimum height
  /// Default: 35% of [panelMaxHeight]
  final double? panelMinHeight;

  /// Panel header maximum size
  ///
  /// Default: 75.0 px
  final double? panelHeaderMaxHeight;

  /// Panel header minimum size,
  ///
  /// which will be use as panel scroll handler
  /// Default: 25.0 px
  final double? panelHeaderMinHeight;

  /// Background color for panel header,
  /// Default: [Colors.black]
  final Color? panelHeaderBackground;

  /// Background color for panel,
  /// Default: [Colors.black]
  final Color? panelBackground;

  /// Point from where panel will start fling animation to snap it's height
  ///
  /// Value must be between 0.0 - 1.0
  /// Default: 0.4
  final double? snapingPoint;

  /// If [panelHeaderBackground] is missing [background] will be applied
  /// If [panelBackground] is missing [background] will be applied
  ///
  /// Default: [Colors.black]
  final Color? background;

  /// Margin for panel top. Which can be used to show status bar if you need
  /// to show panel above scaffold.
  final double? topMargin;
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
