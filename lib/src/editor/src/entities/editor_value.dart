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
    int? maxLines,
    bool? hasFocus,
    bool? hasStickers,
    bool? isEditing,
    bool? isStickerPickerOpen,
    bool? isColorPickerOpen,
  }) {
    return EditorValue(
      textAlign: textAlign ?? this.textAlign,
      keyboardVisible: keyboardVisible ?? this.keyboardVisible,
      fillTextfield: fillTextfield ?? this.fillTextfield,
      maxLines: maxLines ?? this.maxLines,
      hasFocus: hasFocus ?? this.hasFocus,
      hasStickers: hasStickers ?? this.hasStickers,
      isEditing: isEditing ?? this.isEditing,
      isStickerPickerOpen: isStickerPickerOpen ?? this.isStickerPickerOpen,
      isColorPickerOpen: isColorPickerOpen ?? this.isColorPickerOpen,
    );
  }

  @override
  String toString() {
    return '''
    EditorValue(
      textAlign: $textAlign, 
      keyboardVisible: $keyboardVisible, 
      fillTextfield: $fillTextfield, 
      maxLines: $maxLines, 
      hasFocus: $hasFocus, 
      hasStickers: $hasStickers, 
      isEditing: $isEditing, 
      isStickerPickerOpen: $isStickerPickerOpen, 
      isColorPickerOpen: $isColorPickerOpen
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EditorValue &&
        other.textAlign == textAlign &&
        other.keyboardVisible == keyboardVisible &&
        other.fillTextfield == fillTextfield &&
        other.maxLines == maxLines &&
        other.hasFocus == hasFocus &&
        other.hasStickers == hasStickers &&
        other.isEditing == isEditing &&
        other.isStickerPickerOpen == isStickerPickerOpen &&
        other.isColorPickerOpen == isColorPickerOpen;
  }

  @override
  int get hashCode {
    return textAlign.hashCode ^
        keyboardVisible.hashCode ^
        fillTextfield.hashCode ^
        maxLines.hashCode ^
        hasFocus.hashCode ^
        hasStickers.hashCode ^
        isEditing.hashCode ^
        isStickerPickerOpen.hashCode ^
        isColorPickerOpen.hashCode;
  }
}
