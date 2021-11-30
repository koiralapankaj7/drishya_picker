import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class PhotoValue {
  ///
  PhotoValue({
    this.textAlign = TextAlign.center,
    this.fillColor = false,
    this.maxLines = 1,
    this.hasFocus = false,
    this.hasStickers = false,
    this.isEditing = false,
    EditorBackground? background,
    GradientBackground? textBackground,
    this.isStickerPickerOpen = false,
    this.isColorPickerVisible = false,
    this.disableEditing = false,
  })  : background = background ?? gradients[0],
        textBackground = textBackground ?? gradients[0];

  ///
  final TextAlign textAlign;

  ///
  final bool fillColor;

  /// Consider -ve as null
  final int maxLines;

  ///
  final bool hasFocus;

  ///
  final bool hasStickers;

  ///
  final bool isEditing;

  ///
  final EditorBackground background;

  ///
  final GradientBackground textBackground;

  ///
  final bool isStickerPickerOpen;

  ///
  final bool isColorPickerVisible;

  ///
  final bool disableEditing;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  ///
  PhotoValue copyWith({
    TextAlign? textAlign,
    bool? fillColor,
    bool? hasFocus,
    bool? editingMode,
    int? maxLines,
    bool? hasStickers,
    bool? isEditing,
    EditorBackground? background,
    GradientBackground? textBackground,
    bool? isStickerPickerOpen,
    bool? isColorPickerVisible,
    bool? disableEditing,
  }) {
    return PhotoValue(
      textAlign: textAlign ?? this.textAlign,
      fillColor: fillColor ?? this.fillColor,
      hasFocus: hasFocus ?? this.hasFocus,
      maxLines: maxLines ?? this.maxLines,
      hasStickers: hasStickers ?? this.hasStickers,
      isEditing: isEditing ?? this.isEditing,
      background: background ?? this.background,
      textBackground: textBackground ?? this.textBackground,
      isStickerPickerOpen: isStickerPickerOpen ?? this.isStickerPickerOpen,
      isColorPickerVisible: isColorPickerVisible ?? this.isColorPickerVisible,
      disableEditing: disableEditing ?? this.disableEditing,
    );
  }
}
