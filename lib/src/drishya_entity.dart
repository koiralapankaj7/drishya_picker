import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';

///
class DrishyaEntity {
  ///
  DrishyaEntity({
    required this.entity,
    required this.bytes,
  });

  ///
  final AssetEntity entity;

  ///
  final Uint8List bytes;

  @override
  int get hashCode {
    return entity.id.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! DrishyaEntity) {
      return false;
    }
    return entity.id == other.entity.id;
  }

  @override
  String toString() {
    return 'DrishyaEntity{ id:${entity.id} , type: ${entity.type}}';
  }
}
