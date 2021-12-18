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
    this.onPressed,
    this.extra = const {},
  });

  /// The name of the sticker.
  final String name;

  /// The size of the asset. Default Size(100.0, 100.0)
  final Size size;

  /// Sticker onPressed callback
  final ValueSetter<StickerAsset>? onPressed;

  /// Extra information about sticker
  final Map<String, Object> extra;

  /// Build sticker widget
  Widget? build(BuildContext context, DrishyaEditingController controller) =>
      null;
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
    Size size = const Size(200, 200),
    ValueSetter<StickerAsset>? onPressed,
    Map<String, Object> extra = const {},
  }) : super(
          size: size,
          onPressed: onPressed,
          extra: extra,
        );

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

  @override
  Widget? build(BuildContext context, DrishyaEditingController controller) {
    return Container(
      constraints: BoxConstraints.loose(size),
      decoration: BoxDecoration(
        color: background ??
            (withBackground ? controller.value.color : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        child: Text(text, textAlign: textAlign, style: style),
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
    ValueSetter<StickerAsset>? onPressed,
    Map<String, Object> extra = const {},
  }) : super(
          name: name,
          size: size,
          onPressed: onPressed,
          extra: extra,
        );

  /// The url of the sticker. either network/accets or text
  final String path;

  /// Network or asset image
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context, DrishyaEditingController controller) {
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
            secondChild: InkWell(
              onTap: () {
                // onPressed?.call(this);
              },
              child: child,
            ),
            crossFadeState: frame == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          );
        },
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}

///
class IconSticker extends Sticker {
  ///
  const IconSticker({
    required this.iconData,
    String name = '',
    Size size = const Size(100, 100),
    ValueSetter<StickerAsset>? onPressed,
    Map<String, Object> extra = const {},
  }) : super(
          name: name,
          size: size,
          onPressed: onPressed,
          extra: extra,
        );

  ///
  final IconData iconData;

  @override
  Widget? build(BuildContext context, DrishyaEditingController controller) {
    return ValueListenableBuilder<Color>(
      valueListenable: controller.colorNotifier,
      builder: (context, color, child) {
        return FittedBox(
          child: Icon(
            iconData,
            color: color,
          ),
        );
      },
    );
  }
}
