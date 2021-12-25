import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
@immutable
class EditorValue {
  ///
  const EditorValue({
    this.color,
    this.background,
    this.textAlign = TextAlign.center,
    this.keyboardVisible = false,
    this.fillTextfield = false,
    this.maxLines = 1,
    this.hasFocus = false,
    this.hasStickers = false,
    this.isEditing = false,
    this.isStickerPickerOpen = false,
    this.isColorPickerOpen = false,
  });

  /// Background of the editor
  final EditorBackground? background;

  /// Color use to decorate text and icon
  final Color? color;

  /// Alignment of the text
  final TextAlign textAlign;

  /// true, if keyboard is visible
  final bool keyboardVisible;

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
  final bool isColorPickerOpen;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  /// Computed text color as per the background
  Color get textColor => color == null
      ? Colors.black
      : fillTextfield
          ? generateForegroundColor(color!)
          : color!;

  /// Generate foreground color from background color
  Color generateForegroundColor(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  /// true, if color picker is visible currently
  bool get isColorPickerVisible =>
      !isEditing && (isColorPickerOpen || keyboardVisible);

  ///
  EditorValue copyWith({
    TextAlign? textAlign,
    bool? keyboardVisible,
    bool? fillTextfield,
    bool? hasFocus,
    bool? editingMode,
    int? maxLines,
    bool? hasStickers,
    bool? isEditing,
    EditorBackground? background,
    Color? color,
    bool? isStickerPickerOpen,
    bool? isColorPickerOpen,
  }) {
    return EditorValue(
      textAlign: textAlign ?? this.textAlign,
      keyboardVisible: keyboardVisible ?? this.keyboardVisible,
      fillTextfield: fillTextfield ?? this.fillTextfield,
      hasFocus: hasFocus ?? this.hasFocus,
      maxLines: maxLines ?? this.maxLines,
      hasStickers: hasStickers ?? this.hasStickers,
      isEditing: isEditing ?? this.isEditing,
      background: background ?? this.background,
      color: color ?? this.color,
      isStickerPickerOpen: isStickerPickerOpen ?? this.isStickerPickerOpen,
      isColorPickerOpen: isColorPickerOpen ?? this.isColorPickerOpen,
    );
  }

  @override
  int get hashCode => hashValues(
        color,
        background,
        textAlign,
        keyboardVisible,
        fillTextfield,
        maxLines,
        hasFocus,
        hasStickers,
        isEditing,
        isStickerPickerOpen,
        isColorPickerOpen,
      );

  @override
  bool operator ==(Object other) {
    if (other is! EditorValue) {
      return false;
    }
    return color == other.color &&
        background == other.background &&
        textAlign == other.textAlign &&
        keyboardVisible == other.keyboardVisible &&
        fillTextfield == other.fillTextfield &&
        maxLines == other.maxLines &&
        hasFocus == other.hasFocus &&
        hasStickers == other.hasStickers &&
        isEditing == other.isEditing &&
        isStickerPickerOpen == other.isStickerPickerOpen &&
        isColorPickerOpen == other.isColorPickerOpen;
  }
}
