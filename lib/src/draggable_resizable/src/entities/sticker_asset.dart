import 'package:flutter/widgets.dart';

///
class StickerAsset {
  ///
  const StickerAsset({
    required this.id,
    required this.sticker,
    this.angle = 0.0,
    this.constraint = const StickerConstraint(),
    this.position = const StickerPosition(),
    this.size = const StickerSize(),
  });

  ///
  final String id;

  ///
  final Sticker sticker;

  ///
  final double angle;

  ///
  final StickerConstraint constraint;

  ///
  final StickerPosition position;

  ///
  final StickerSize size;

  ///
  StickerAsset copyWith({
    Sticker? sticker,
    double? angle,
    StickerConstraint? constraint,
    StickerPosition? position,
    StickerSize? size,
  }) {
    return StickerAsset(
      id: id,
      sticker: sticker ?? this.sticker,
      angle: angle ?? this.angle,
      constraint: constraint ?? this.constraint,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

///
class StickerConstraint {
  ///
  const StickerConstraint({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;
}

///
class StickerSize {
  ///
  const StickerSize({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;
}

///
class StickerPosition {
  ///
  const StickerPosition({this.dx = 0, this.dy = 0});

  ///
  final double dx;

  ///
  final double dy;
}

/// {@template asset}
/// A Dart object which holds metadata for a given sticker.
/// {@endtemplate}
class Sticker {
  /// {@macro asset}
  const Sticker({
    this.name,
    this.path,
    this.size = const Size(200.0, 250.0),
    this.pathType = StickerPathType.none,
    this.widget,
  });

  /// The name of the sticker.
  final String? name;

  /// The url of the sticker. either network/accets or text
  final String? path;

  ///
  final StickerPathType pathType;

  /// The size of the asset. Default Size(100.0, 100.0)
  final Size size;

  ///
  final Widget? widget;
}

///
enum StickerPathType {
  ///
  text,

  ///
  networkImg,

  ///
  assetsImage,

  ///
  none,
}
