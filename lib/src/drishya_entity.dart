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
  }) : super(
          id: id,
          height: height,
          width: width,
          typeInt: typeInt,
        );

  /// Thumb bytes of image and video. Dont use this for other asset types.
  /// This
  final Uint8List? pickedThumbData;

  /// Field where asset is stored
  final File? pickedFile;

  // /// in android is database _id column
  // ///
  // /// in ios is local id
  // String get id => entity.id;

  // /// the asset type
  // ///
  // /// see [AssetType]
  // AssetType get type => entity.type;

  // /// Asset type int value.
  // ///
  // /// see [type]
  // int get typeInt => entity.typeInt;

  // /// if not video, duration is 0
  // Duration get videoDuration => entity.videoDuration;

  // /// The [Size] for the asset.
  // Size get size => entity.size;

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
        pickedThumbData: pickedThumbData ?? this.pickedThumbData,
        pickedFile: pickedFile ?? this.pickedFile,
      );

  // @override
  // int get hashCode => id.hashCode;

  // @override
  // bool operator ==(Object other) {
  //   if (other is! DrishyaEntity) return false;
  //   return id == other.id;
  // }

  // @override
  // String toString() {
  //   return 'DrishyaEntity{ id : $id , type: $type}';
  // }
}

/// AssetEntity extension
extension AssetEntityX on AssetEntity {
  /// Convert [AssetEntity] to [DrishyaEntity]
  DrishyaEntity get toDrishya => DrishyaEntity(
        id: id,
        width: width,
        height: height,
        typeInt: typeInt,
      );
}
