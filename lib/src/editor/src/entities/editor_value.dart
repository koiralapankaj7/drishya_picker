import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class EditorValue {
  ///
  EditorValue({
    required this.color,
    required this.background,
    this.textAlign = TextAlign.center,
    this.fillTextfield = false,
    this.maxLines = 1,
    this.hasFocus = false,
    this.hasStickers = false,
    this.isEditing = false,
    this.isStickerPickerOpen = false,
    this.isColorPickerVisible = false,
  });

  /// Background of the editor
  final EditorBackground background;

  /// Color use to decorate text and icon
  final Color color;

  /// Alignment of the text
  final TextAlign textAlign;

  /// if true, textfield will be filled by [color]
  final bool fillTextfield;

  /// Consider -ve as null
  final int maxLines;

  /// true, if textfield is active/focused
  final bool hasFocus;

  /// true, if editor has stickers
  final bool hasStickers;

  /// true, if editing is ongoing
  final bool isEditing;

  /// true, if sticker picker is currently open
  final bool isStickerPickerOpen;

  /// true, if color picker is visible
  final bool isColorPickerVisible;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  /// Computed text color as per the background
  Color get textColor {
    final c = !fillTextfield
        ? color
        : color.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;
    return c;
  }

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
    Color? color,
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
      color: color ?? this.color,
      isStickerPickerOpen: isStickerPickerOpen ?? this.isStickerPickerOpen,
      isColorPickerVisible: isColorPickerVisible ?? this.isColorPickerVisible,
    );
  }
}
