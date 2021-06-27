import 'package:flutter/material.dart';

///
class TFValue {
  ///
  const TFValue({
    this.textAlign = TextAlign.center,
    this.fillColor = Colors.transparent,
    this.maxLines = 1,
    this.hasFocus = false,
  });

  ///
  final TextAlign textAlign;

  ///
  final Color fillColor;

  /// treate -ve as null
  final int maxLines;

  ///
  final bool hasFocus;

  /// -ve number as null
  int? get convertedMaxLines => maxLines.isNegative ? null : maxLines;

  ///
  TFValue copyWith({
    TextAlign? textAlign,
    Color? fillColor,
    bool? hasFocus,
    int? maxLines,
  }) {
    return TFValue(
      textAlign: textAlign ?? this.textAlign,
      fillColor: fillColor ?? this.fillColor,
      hasFocus: hasFocus ?? this.hasFocus,
      maxLines: maxLines ?? this.maxLines,
    );
  }
}
