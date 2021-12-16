import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class EditorValue {
  ///
  EditorValue({
    this.textAlign = TextAlign.center,
    this.fillTextfield = false,
    this.maxLines = 1,
    this.hasFocus = false,
    this.hasStickers = false,
    this.isEditing = false,
    this.background,
    this.textColor,
    this.isStickerPickerOpen = false,
    this.isColorPickerVisible = false,
  });

  ///
  final TextAlign textAlign;

  ///
  final bool fillTextfield;

  /// Consider -ve as null
  final int maxLines;

  ///
  final bool hasFocus;

  ///
  final bool hasStickers;

  ///
  final bool isEditing;

  ///
  final EditorBackground? background;

  ///
  final Color? textColor;

  ///
  final bool isStickerPickerOpen;

  ///
  final bool isColorPickerVisible;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  ///
  EditorValue copyWith({
    TextAlign? textAlign,
    bool? fillTextfield,
    bool? hasFocus,
    bool? editingMode,
    int? maxLines,
    bool? hasStickers,
    bool? isEditing,
    EditorBackground? background,
    Color? textColor,
    bool? isStickerPickerOpen,
    bool? isColorPickerVisible,
  }) {
    return EditorValue(
      textAlign: textAlign ?? this.textAlign,
      fillTextfield: fillTextfield ?? this.fillTextfield,
      hasFocus: hasFocus ?? this.hasFocus,
      maxLines: maxLines ?? this.maxLines,
      hasStickers: hasStickers ?? this.hasStickers,
      isEditing: isEditing ?? this.isEditing,
      background: background ?? this.background,
      textColor: textColor ?? this.textColor,
      isStickerPickerOpen: isStickerPickerOpen ?? this.isStickerPickerOpen,
      isColorPickerVisible: isColorPickerVisible ?? this.isColorPickerVisible,
    );
  }
}
