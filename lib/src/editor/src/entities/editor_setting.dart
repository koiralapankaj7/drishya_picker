import 'package:collection/collection.dart';
import 'package:drishya_picker/assets/icons/shape_icons.dart';
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
  // : assert(
  //         _defaultBackgrounds.isNotEmpty,
  //         'gradientBackgrounds property must have atleast one value',
  //       ),
  //       assert(
  //         colors.isNotEmpty,
  //         'colors property must have atleast one value',
  //       );

  /// Stickers for the editor
  final Map<String, Set<Sticker>>? stickers;

  /// Editor backgrounds
  final List<EditorBackground> backgrounds;

  /// If sticker picker tab size exceed [fixedTabSize], tab will be scrollable
  /// otherwise it will be fixed. Default is 4
  final int fixedTabSize;

  ///
  /// [PhotoBackground] => Colors will be used to change text/icon colors
  /// [GradientBackground] => Colors will be used to change icon colors
  ///
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

///
final stickers = {'ARTS': _arts, 'EMOJIS': _gifs, 'SHAPES': _shapes};

///
const _gifs = {
  ImageSticker(
    name: 'No Way',
    path: 'https://media.giphy.com/media/USUIWSteF8DJoc5Snd/giphy.gif',
  ),
  ImageSticker(
    name: 'Sad Face',
    path: 'https://media.giphy.com/media/h4OGa0npayrJX2NRPT/giphy.gif',
  ),
  ImageSticker(
    name: 'Angry Face',
    path: 'https://media.giphy.com/media/j5E5qvtLDTfmHbT84Y/giphy.gif',
  ),
  ImageSticker(
    name: 'Sad Miss You',
    path: 'https://media.giphy.com/media/IzcFv6WJ4310bDeGjo/giphy.gif',
  ),
  ImageSticker(
    name: 'Angry Face',
    path: 'https://media.giphy.com/media/kyQfR7MlQQ9Gb8URKG/giphy.gif',
  ),
  ImageSticker(
    name: 'Smiley Face Love',
    path: 'https://media.giphy.com/media/hof5uMY0nBwxyjY9S2/giphy.gif',
  ),
  ImageSticker(
    name: 'Sad Face',
    path: 'https://media.giphy.com/media/kfS15Gnvf9UhkwafJn/giphy.gif',
  ),
  ImageSticker(
    name: 'Crying',
    path: 'https://media.giphy.com/media/ViHbdDMcIOeLeblrbq/giphy.gif',
  ),
  ImageSticker(
    name: 'Wow',
    path: 'https://media.giphy.com/media/XEyXIfu7IRQivZl1Mw/giphy.gif',
  ),
  ImageSticker(
    name: 'Fuckboy',
    path: 'https://media.giphy.com/media/Kd5vjqlBqOhLsu3Rna/giphy.gif',
  ),
  ImageSticker(
    name: 'Bless You',
    path: 'https://media.giphy.com/media/WqR7WfQVrpXNcmrm81/giphy.gif',
  ),
  ImageSticker(
    name: 'As If Whatever',
    path: 'https://media.giphy.com/media/Q6xFPLfzfsgKoKDV60/giphy.gif',
  ),
  ImageSticker(
    name: 'Sick face',
    path: 'https://media.giphy.com/media/W3CLbW0KY3RtjsqtYO/giphy.gif',
  ),
  ImageSticker(
    name: 'Birthday cake',
    path: 'https://media.giphy.com/media/l4RS2PG61HIYiukdoT/giphy.gif',
  ),
  ImageSticker(
    name: 'Embarrassed Face',
    path: 'https://media.giphy.com/media/kyzzHEoaLAAr9nX4fy/giphy.gif',
  ),
};

///
const _arts = {
  ImageSticker(
    name: 'Smoke',
    path:
        'https://pngimage.net/wp-content/uploads/2018/06/%D1%87%D0%B5%D1%80%D0%BD%D1%8B%D0%B9-%D0%B4%D1%8B%D0%BC-png-2.png',
  ),
  ImageSticker(
    name: 'Multiple circles',
    path:
        'https://static.vecteezy.com/system/resources/previews/001/192/216/original/circle-png.png',
  ),
  ImageSticker(
    name: 'Eagle Wings',
    path: 'https://www.freeiconspng.com/uploads/angel-png-1.png',
  ),
  ImageSticker(
    name: 'Hair',
    path:
        'https://cdn.statically.io/img/kreditings.com/wp-content/uploads/2020/09/hair-png.png?quality=100&f=auto',
  ),
  ImageSticker(
    name: 'Cloud',
    path:
        'https://i.pinimg.com/originals/19/8d/ae/198daeda14097d45e417e62ff283f10e.png',
  ),
  ImageSticker(
    name: 'Abstract art',
    path:
        'https://freepngimg.com/download/graphic/53280-2-abstract-art-hd-free-png-hq.png',
  ),
  ImageSticker(
    name: 'Hair',
    path:
        'https://i.pinimg.com/originals/df/8b/f1/df8bf1a18047ff20d3f82e0f47dbe683.png',
  ),
  ImageSticker(
    path: 'https://freepngimg.com/thumb/hair/21-women-hair-png-image-thumb.png',
  ),
  ImageSticker(
    name: 'Paint splatter',
    path:
        'https://pngimage.net/wp-content/uploads/2018/06/paint-splatter-png-6.png',
  ),
  ImageSticker(
    name: 'Hair',
    path: 'https://pngimg.com/uploads/hair/hair_PNG5637.png',
  ),
  ImageSticker(
    name: 'Hair',
    path: 'https://www.pngarts.com/files/4/Picsart-PNG-Background-Image.png',
  ),
  ImageSticker(
    name: 'Eagle',
    path:
        'https://www.pngkey.com/png/full/0-9646_american-eagle-logo-png-eagle-holding-lombardi-trophy.png',
  ),
  ImageSticker(
    name: 'Hair',
    path:
        'https://i.dlpng.com/static/png/1357097-cb-hair-png-hair-png-521_500_preview.png',
  ),
  ImageSticker(
    name: 'Art',
    path: 'https://i.dlpng.com/static/png/6719469_preview.png',
  ),
  ImageSticker(
    name: 'Bird',
    path:
        'https://storage.needpix.com/rsynced_images/no-background-2997564_1280.png',
  ),
  ImageSticker(
    name: 'Eagle',
    path:
        'https://cdn.pixabay.com/photo/2017/12/13/23/27/no-background-3017971_1280.png',
  ),
};

///
final _shapes = ShapeIcons.values
    .map((iconData) => IconSticker(iconData: iconData))
    .toSet();
