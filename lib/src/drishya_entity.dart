import 'dart:io';
import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';

///
class DrishyaEntity extends AssetEntity {
  ///
  DrishyaEntity({
    required String id,
    required int height,
    required int width,
    required int typeInt,
    this.pickedThumbData,
    this.pickedFile,
    int duration = 0,
    int orientation = 0,
    bool isFavorite = false,
    String? title,
    int? createDtSecond,
    int? modifiedDateSecond,
    String? relativePath,
    double? latitude,
    double? longitude,
    String? mimeType,
  }) : super(
          id: id,
          height: height,
          width: width,
          typeInt: typeInt,
          duration: duration,
          orientation: orientation,
          isFavorite: isFavorite,
          title: title,
          createDtSecond: createDtSecond,
          modifiedDateSecond: modifiedDateSecond,
          relativePath: relativePath,
          latitude: latitude,
          longitude: longitude,
          mimeType: mimeType,
        );

  /// Thumb bytes of image and video. Dont use this for other asset types.
  /// This
  final Uint8List? pickedThumbData;

  /// Field where asset is stored
  final File? pickedFile;

  ///
  ///
  DrishyaEntity copyWith({
    Uint8List? pickedThumbData,
    File? pickedFile,
  }) =>
      DrishyaEntity(
        id: id,
        width: width,
        height: height,
        typeInt: typeInt,
        duration: duration,
        orientation: orientation,
        isFavorite: isFavorite,
        title: title,
        createDtSecond: createDtSecond,
        modifiedDateSecond: modifiedDateSecond,
        relativePath: relativePath,
        latitude: latitude,
        longitude: longitude,
        mimeType: mimeType,
        pickedThumbData: pickedThumbData ?? this.pickedThumbData,
        pickedFile: pickedFile ?? this.pickedFile,
      );
}

/// AssetEntity extension
extension AssetEntityX on AssetEntity {
  /// Convert [AssetEntity] to [DrishyaEntity]
  DrishyaEntity get toDrishya => DrishyaEntity(
        id: id,
        width: width,
        height: height,
        typeInt: typeInt,
        duration: duration,
        orientation: orientation,
        isFavorite: isFavorite,
        title: title,
        createDtSecond: createDtSecond,
        modifiedDateSecond: modifiedDateSecond,
        relativePath: relativePath,
        latitude: latitude,
        longitude: longitude,
        mimeType: mimeType,
      );
}
