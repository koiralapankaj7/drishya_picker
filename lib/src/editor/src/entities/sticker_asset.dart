import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
@immutable
class StickerAsset {
  ///
  const StickerAsset({
    required this.id,
    required this.sticker,
    this.angle = 0.0,
    this.constraint = const StickerConstraint(),
    this.position = const StickerPosition(),
    this.size = const StickerSize(),
    this.scale = 1.0,
  });

  /// Sticker asset id
  final String id;

  /// Sticker
  final Sticker sticker;

  /// Sticker angle
  final double angle;

  /// Sticker constraint
  final StickerConstraint constraint;

  /// Sticker position
  final StickerPosition position;

  /// Sticker size
  final StickerSize size;

  /// Sticker scale value
  final double scale;

  ///
  StickerAsset copyWith({
    String? id,
    Sticker? sticker,
    double? angle,
    StickerConstraint? constraint,
    StickerPosition? position,
    StickerSize? size,
    double? scale,
  }) {
    return StickerAsset(
      id: id ?? this.id,
      sticker: sticker ?? this.sticker,
      angle: angle ?? this.angle,
      constraint: constraint ?? this.constraint,
      position: position ?? this.position,
      size: size ?? this.size,
      scale: scale ?? this.scale,
    );
  }

  @override
  String toString() {
    return '''
    StickerAsset(
      id: $id, 
      sticker: $sticker, 
      angle: $angle, 
      constraint: $constraint, 
      position: $position, 
      size: $size, 
      scale: $scale
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerAsset &&
        other.id == id &&
        other.sticker == sticker &&
        other.angle == angle &&
        other.constraint == constraint &&
        other.position == position &&
        other.size == size &&
        other.scale == scale;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sticker.hashCode ^
        angle.hashCode ^
        constraint.hashCode ^
        position.hashCode ^
        size.hashCode ^
        scale.hashCode;
  }
}

///
@immutable
class StickerConstraint {
  /// Sticker constraints
  const StickerConstraint({this.width = 1, this.height = 1});

  /// Sticker width constraint
  final double width;

  /// Sticker height constraint
  final double height;

  /// Sticker constraint size
  Size get size => Size(width, height);

  /// Box constraints
  BoxConstraints get boxConstraints => BoxConstraints(
        minWidth: width,
        minHeight: height,
      );

  ///
  StickerConstraint copyWith({
    double? width,
    double? height,
  }) {
    return StickerConstraint(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  String toString() => 'StickerConstraint(width: $width, height: $height)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerConstraint &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}

///
@immutable
class StickerSize {
  ///
  const StickerSize({this.width = 1, this.height = 1});

  /// Sticker width
  final double width;

  /// Sticker height
  final double height;

  /// Size from the sticker size
  Size get size => Size(width, height);

  ///
  StickerSize copyWith({
    double? width,
    double? height,
  }) {
    return StickerSize(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  String toString() => 'StickerSize(width: $width, height: $height)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerSize &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}

///
@immutable
class StickerPosition {
  /// Sticker position in the screen
  const StickerPosition({this.dx = 0, this.dy = 0});

  /// position on x-axis
  final double dx;

  /// position on y-axis
  final double dy;

  /// Position offset
  Offset get offset => Offset(dx, dy);

  ///
  StickerPosition copyWith({
    double? dx,
    double? dy,
  }) {
    return StickerPosition(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
    );
  }

  @override
  String toString() => 'StickerPosition(dx: $dx, dy: $dy)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerPosition && other.dx == dx && other.dy == dy;
  }

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode;
}

/// {@template sticker}
/// A Dart object which holds metadata for a given sticker.
/// {@endtemplate}
abstract class Sticker {
  /// {@macro sticker}
  const Sticker({
    this.name = '',
    this.size = const Size(200, 200),
    this.extra = const {},
  });

  /// The name of the sticker.
  final String name;

  /// The size of the asset. Default Size(100.0, 100.0)
  final Size size;

  /// Extra information about sticker
  final Map<String, Object> extra;

  /// Build sticker
  Widget build(
    BuildContext context,
    DrishyaEditingController controller,
    VoidCallback? onPressed,
    StickerAsset? asset,
  );

  //
}

///
@immutable
class TextSticker extends Sticker {
  ///
  const TextSticker({
    Size size = const Size(200, 200),
    Map<String, Object> extra = const {},
    this.text = '',
    this.style,
    this.textAlign,
    this.background,
  }) : super(size: size, extra: extra);

  ///
  final String text;

  ///
  final TextStyle? style;

  ///
  final TextAlign? textAlign;

  ///
  final Color? background;

  @override
  Widget build(
    BuildContext context,
    DrishyaEditingController controller,
    VoidCallback? onPressed,
    StickerAsset? asset,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            textAlign: textAlign,
            style: style,
          ),
        ),
      ),
    );
  }

  ///
  TextSticker copyWith({
    String? text,
    TextStyle? style,
    TextAlign? textAlign,
    Color? background,
  }) {
    return TextSticker(
      text: text ?? this.text,
      style: style ?? this.style,
      textAlign: textAlign ?? this.textAlign,
      background: background ?? this.background,
    );
  }

  @override
  String toString() {
    return '''
    TextSticker(
      text: $text, 
      style: $style, 
      textAlign: $textAlign, 
      background: $background
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextSticker &&
        other.text == text &&
        other.style == style &&
        other.textAlign == textAlign &&
        other.background == background;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        style.hashCode ^
        textAlign.hashCode ^
        background.hashCode;
  }
}

///
@immutable
class ImageSticker extends Sticker {
  ///
  const ImageSticker({
    String name = '',
    Size size = const Size(200, 200),
    Map<String, Object> extra = const {},
    this.path = '',
    this.isNetworkImage = true,
  }) : super(name: name, size: size, extra: extra);

  /// The url of the sticker. either network/accets or text
  final String path;

  /// Network or asset image
  final bool isNetworkImage;

  @override
  Widget build(
    BuildContext context,
    DrishyaEditingController controller,
    VoidCallback? onPressed,
    StickerAsset? asset,
  ) {
    if (isNetworkImage) {
      return Image.network(
        path,
        frameBuilder: (
          BuildContext context,
          Widget child,
          int? frame,
          bool wasSynchronouslyLoaded,
        ) {
          return AppAnimatedCrossFade(
            firstChild: SizedBox.fromSize(
              size: const Size(20, 20),
              child: const AppCircularProgressIndicator(strokeWidth: 2),
            ),
            secondChild: onPressed != null
                ? InkWell(
                    onTap: onPressed,
                    child: child,
                  )
                : child,
            crossFadeState: frame == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          );
        },
      );
    }

    final img = Image.asset(
      path,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );

    if (onPressed == null) return img;

    return InkWell(onTap: onPressed, child: img);
  }

  ///
  ImageSticker copyWith({
    String? path,
    bool? isNetworkImage,
  }) {
    return ImageSticker(
      path: path ?? this.path,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
    );
  }

  @override
  String toString() =>
      'ImageSticker(path: $path, isNetworkImage: $isNetworkImage)';
}

///
@immutable
class IconSticker extends Sticker {
  ///
  const IconSticker({
    required this.iconData,
    this.color,
    String name = '',
    Size size = const Size(100, 100),
    Map<String, Object> extra = const {},
  }) : super(
          name: name,
          size: size,
          extra: extra,
        );

  ///
  final IconData iconData;

  ///
  final Color? color;

  @override
  Widget build(
    BuildContext context,
    DrishyaEditingController controller,
    VoidCallback? onPressed,
    StickerAsset? asset,
  ) {
    return ValueListenableBuilder<Color>(
      valueListenable: controller.colorNotifier,
      builder: (context, c, child) {
        final icon = FittedBox(
          child: Icon(
            iconData,
            color: color ?? c,
          ),
        );

        if (onPressed == null) return icon;

        return InkWell(onTap: onPressed, child: icon);
      },
    );
  }

  /// Copy object
  IconSticker copyWith({
    IconData? iconData,
    Color? color,
  }) {
    return IconSticker(
      iconData: iconData ?? this.iconData,
      color: color ?? this.color,
    );
  }

  @override
  String toString() => 'IconSticker(iconData: $iconData, color: $color)';
}
