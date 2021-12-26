import 'package:flutter/material.dart';

///
@immutable
class EditorValue {
  ///
  const EditorValue({
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

  /// Alignment of the text
  final TextAlign textAlign;

  /// true, if keyboard is visible
  final bool keyboardVisible;

  /// if true, textfield will be filled
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
      isStickerPickerOpen: isStickerPickerOpen ?? this.isStickerPickerOpen,
      isColorPickerOpen: isColorPickerOpen ?? this.isColorPickerOpen,
    );
  }

  @override
  int get hashCode => hashValues(
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
    return textAlign == other.textAlign &&
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
