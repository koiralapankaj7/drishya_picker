import 'package:flutter/material.dart';

import 'playground_background.dart';

///
class PlaygroundValue {
  ///
  PlaygroundValue({
    this.textAlign = TextAlign.center,
    this.fillColor = Colors.transparent,
    this.maxLines = 1,
    this.hasFocus = false,
    // this.editingMode = false,
    this.hasStickers = false,
    this.isEditing = false,
    PlaygroundBackground? background,
  }) : background = background ?? gradients[0];

  ///
  final TextAlign textAlign;

  ///
  final Color fillColor;

  /// treate -ve as null
  final int maxLines;

  ///
  final bool hasFocus;

  ///
  // final bool editingMode;

  ///
  final bool hasStickers;

  ///
  final bool isEditing;

  ///
  final PlaygroundBackground background;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  ///
  PlaygroundValue copyWith({
    TextAlign? textAlign,
    Color? fillColor,
    bool? hasFocus,
    bool? editingMode,
    int? maxLines,
    bool? hasStickers,
    bool? isEditing,
    PlaygroundBackground? background,
  }) {
    return PlaygroundValue(
      textAlign: textAlign ?? this.textAlign,
      fillColor: fillColor ?? this.fillColor,
      hasFocus: hasFocus ?? this.hasFocus,
      // editingMode: editingMode ?? this.editingMode,
      maxLines: maxLines ?? this.maxLines,
      hasStickers: hasStickers ?? this.hasStickers,
      isEditing: isEditing ?? this.isEditing,
      background: background ?? this.background,
    );
  }
}
