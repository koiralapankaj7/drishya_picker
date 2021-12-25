import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

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
    this.scale = 1.0,
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
  final double scale;

  ///
  StickerAsset copyWith({
    Sticker? sticker,
    double? angle,
    StickerConstraint? constraint,
    StickerPosition? position,
    StickerSize? size,
    double? scale,
  }) {
    return StickerAsset(
      id: id,
      sticker: sticker ?? this.sticker,
      angle: angle ?? this.angle,
      constraint: constraint ?? this.constraint,
      position: position ?? this.position,
      size: size ?? this.size,
      scale: scale ?? this.scale,
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

  ///
  Size get size => Size(width, height);

  ///
  BoxConstraints get boxConstraints => BoxConstraints(
        minWidth: width,
        minHeight: height,
      );
}

///
class StickerSize {
  ///
  const StickerSize({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;

  ///
  Size get size => Size(width, height);
}

///
class StickerPosition {
  ///
  const StickerPosition({this.dx = 0, this.dy = 0});

  ///
  final double dx;

  ///
  final double dy;

  ///
  Offset get offset => Offset(dx, dy);
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
class TextSticker extends Sticker {
  ///
  const TextSticker({
    this.text = '',
    this.style,
    this.withBackground = false,
    this.textAlign,
    this.background,
    this.originalSize = Size.zero,
    Size size = const Size(200, 200),
    Map<String, Object> extra = const {},
  }) : super(size: size, extra: extra);

  ///
  final String text;

  ///
  final TextStyle? style;

  ///
  final TextAlign? textAlign;

  ///
  final bool withBackground;

  ///
  final Color? background;

  ///
  final Size originalSize;

  @override
  Widget build(
    BuildContext context,
    DrishyaEditingController controller,
    VoidCallback? onPressed,
    StickerAsset? asset,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ??
            (withBackground ? controller.value.color : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(text, textAlign: textAlign, style: style),
        ),
      ),
    );
  }
}

///
class ImageSticker extends Sticker {
  ///
  const ImageSticker({
    this.path = '',
    this.isNetworkImage = true,
    String name = '',
    Size size = const Size(200, 200),
    Map<String, Object> extra = const {},
  }) : super(
          name: name,
          size: size,
          extra: extra,
        );

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
}

///
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

  /// Copy object
  IconSticker copyWith({
    IconData? iconData,
    Color? color,
    String? name,
    Size? size,
    Map<String, Object>? extra,
  }) =>
      IconSticker(
        iconData: iconData ?? this.iconData,
        color: color ?? this.color,
        extra: extra ?? this.extra,
        name: name ?? this.name,
        size: size ?? this.size,
      );

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
}
