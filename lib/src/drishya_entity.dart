import 'dart:io';
import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class DrishyaEntity {
  ///
  DrishyaEntity({
    required this.entity,
    required this.bytes,
    required this.file,
  });

  /// Core sssets object which hold complete details of the asset
  final AssetEntity entity;

  /// Bytes of the asset
  final Uint8List bytes;

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

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    if (other is! DrishyaEntity) return false;
    return id == other.id;
  }

  @override
  String toString() {
    return 'DrishyaEntity{ id : $id , type: $type}';
  }
}
