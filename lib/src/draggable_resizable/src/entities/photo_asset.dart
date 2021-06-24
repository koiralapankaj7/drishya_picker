import 'package:flutter/widgets.dart';

///
class PhotoConstraint {
  ///
  const PhotoConstraint({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;
}

///
class PhotoAssetSize {
  ///
  const PhotoAssetSize({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;
}

///
class PhotoAssetPosition {
  ///
  const PhotoAssetPosition({this.dx = 0, this.dy = 0});

  ///
  final double dx;

  ///
  final double dy;
}

///
class PhotoAsset {
  ///
  const PhotoAsset({
    required this.id,
    required this.asset,
    this.angle = 0.0,
    this.constraint = const PhotoConstraint(),
    this.position = const PhotoAssetPosition(),
    this.size = const PhotoAssetSize(),
  });

  ///
  final String id;

  ///
  final Asset asset;

  ///
  final double angle;

  ///
  final PhotoConstraint constraint;

  ///
  final PhotoAssetPosition position;

  ///
  final PhotoAssetSize size;

  ///
  PhotoAsset copyWith({
    Asset? asset,
    double? angle,
    PhotoConstraint? constraint,
    PhotoAssetPosition? position,
    PhotoAssetSize? size,
  }) {
    return PhotoAsset(
      id: id,
      asset: asset ?? this.asset,
      angle: angle ?? this.angle,
      constraint: constraint ?? this.constraint,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

/// {@template asset}
/// A Dart object which holds metadata for a given asset.
/// {@endtemplate}
class Asset {
  /// {@macro asset}
  const Asset({
    required this.name,
    required this.path,
    required this.size,
  });

  /// The name of the image.
  final String name;

  /// The path to the asset.
  final String path;

  /// The size of the asset.
  final Size size;
}
