import 'package:collection/collection.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
@immutable
class EditorSetting {
  ///
  const EditorSetting({
    this.stickers,
    this.backgrounds = _defaultBackgrounds,
    this.fixedTabSize = 4,
    this.colors = _colors,
  });

  /// Stickers for the editor
  final Map<String, Set<Sticker>>? stickers;

  /// Editor backgrounds
  final List<EditorBackground> backgrounds;

  /// If sticker picker tab size exceed [fixedTabSize], tab will be scrollable
  /// otherwise it will be fixed. Default is 4
  final int fixedTabSize;

  ///
  ///  Colors will be used to change icon/text colors
  final List<Color> colors;

  /// Helper function to copy object
  EditorSetting copyWith({
    Map<String, Set<Sticker>>? stickers,
    List<EditorBackground>? backgrounds,
    int? fixedTabSize,
    List<Color>? colors,
  }) {
    return EditorSetting(
      stickers: stickers ?? this.stickers,
      backgrounds: backgrounds ?? this.backgrounds,
      fixedTabSize: fixedTabSize ?? this.fixedTabSize,
      colors: colors ?? this.colors,
    );
  }

  /// Default backgrounds
  List<GradientBackground> get defaultBackgrounds => _defaultBackgrounds;

  /// Default colors
  List<Color> get defaultColors => _colors;

  @override
  String toString() {
    return '''
    EditorSetting(
      stickers: $stickers, 
      backgrounds: $backgrounds, 
      fixedTabSize: $fixedTabSize, 
      colors: $colors
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return other is EditorSetting &&
        collectionEquals(other.stickers, stickers) &&
        collectionEquals(other.backgrounds, backgrounds) &&
        other.fixedTabSize == fixedTabSize &&
        collectionEquals(other.colors, colors);
  }

  @override
  int get hashCode {
    return stickers.hashCode ^
        backgrounds.hashCode ^
        fixedTabSize.hashCode ^
        colors.hashCode;
  }
}

///
const _defaultBackgrounds = [
  GradientBackground(colors: [Color(0xFF00C6FF), Color(0xFF0078FF)]),
  GradientBackground(colors: [Color(0xFFeb3349), Color(0xFFf45c43)]),
  GradientBackground(colors: [Color(0xFF26a0da), Color(0xFF314755)]),
  GradientBackground(colors: [Color(0xFFe65c00), Color(0xFFF9D423)]),
  GradientBackground(colors: [Color(0xFFfc6767), Color(0xFFec008c)]),
  GradientBackground(
    colors: [Color(0xFF5433FF), Color(0xFF20BDFF), Color(0xFFA5FECB)],
  ),
  GradientBackground(colors: [Color(0xFF334d50), Color(0xFFcbcaa5)]),
  GradientBackground(colors: [Color(0xFF1565C0), Color(0xFFb92b27)]),
  GradientBackground(
    colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFFA5FECB)],
  ),
  GradientBackground(colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)]),
  GradientBackground(colors: [Color(0xFF753a88), Color(0xFFcc2b5e)]),
];

const _colors = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.yellow,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.orange,
];
