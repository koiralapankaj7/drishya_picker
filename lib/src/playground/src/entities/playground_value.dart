import 'package:flutter/material.dart';

import 'playground_background.dart';

///
class PlaygroundValue {
  ///
  PlaygroundValue({
    this.textAlign = TextAlign.center,
    this.fillColor = false,
    this.maxLines = 1,
    this.hasFocus = false,
    this.hasStickers = false,
    this.isEditing = false,
    PlaygroundBackground? background,
    GradientBackground? textBackground,
    this.stickerPickerView = false,
    this.colorPickerVisibility = false,
  })  : background = background ?? gradients[0],
        textBackground = textBackground ?? gradients[0];

  ///
  final TextAlign textAlign;

  ///
  final bool fillColor;

  /// treate -ve as null
  final int maxLines;

  ///
  final bool hasFocus;

  ///
  final bool hasStickers;

  ///
  final bool isEditing;

  ///
  final PlaygroundBackground background;

  ///
  final GradientBackground textBackground;

  ///
  final bool stickerPickerView;

  ///
  final bool colorPickerVisibility;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  ///
  PlaygroundValue copyWith(
      {TextAlign? textAlign,
      bool? fillColor,
      bool? hasFocus,
      bool? editingMode,
      int? maxLines,
      bool? hasStickers,
      bool? isEditing,
      PlaygroundBackground? background,
      GradientBackground? textBackground,
      bool? stickerPickerView,
      bool? colorPickerVisibility}) {
    return PlaygroundValue(
      textAlign: textAlign ?? this.textAlign,
      fillColor: fillColor ?? this.fillColor,
      hasFocus: hasFocus ?? this.hasFocus,
      maxLines: maxLines ?? this.maxLines,
      hasStickers: hasStickers ?? this.hasStickers,
      isEditing: isEditing ?? this.isEditing,
      background: background ?? this.background,
      textBackground: textBackground ?? this.textBackground,
      stickerPickerView: stickerPickerView ?? this.stickerPickerView,
      colorPickerVisibility:
          colorPickerVisibility ?? this.colorPickerVisibility,
    );
  }
}
