import 'dart:io';
import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
@immutable
class DrishyaEntity {
  ///
  const DrishyaEntity({
    required this.entity,
    required this.thumbBytes,
    required this.file,
  });

  /// Core sssets object which hold complete details of the asset
  final AssetEntity entity;

  /// Thumb bytes of image and video. Dont use this for other asset types.
  final Uint8List thumbBytes;

  /// Field where asset is stored
  final File file;

  /// in android is database _id column
  ///
  /// in ios is local id
  String get id => entity.id;

  /// the asset type
  ///
  /// see [AssetType]
  AssetType get type => entity.type;

  /// Asset type int value.
  ///
  /// see [type]
  int get typeInt => entity.typeInt;

  /// if not video, duration is 0
  Duration get videoDuration => entity.videoDuration;

  /// The [Size] for the asset.
  Size get size => entity.size;

  ///
  DrishyaEntity copyWith({
    Uint8List? thumbBytes,
    File? file,
  }) =>
      DrishyaEntity(
        entity: entity,
        thumbBytes: thumbBytes ?? this.thumbBytes,
        file: file ?? this.file,
      );

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! DrishyaEntity) return false;
    return other == this || id == other.id;
  }

  @override
  String toString() {
    return 'DrishyaEntity{ id : $id , type: $type}';
  }
}
