import 'package:drishya_picker/assets/icons/shape_icons.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class EditorSetting {
  ///
  EditorSetting({
    this.stickers,
    this.background,
    this.backgrounds,
    this.gradients,
    this.fixedTabSize = 4,
    this.colors = _colors,
  }) : assert(
          colors.isNotEmpty,
          'colors property must have atleast one value',
        );

  ///
  final Map<String, Set<Sticker>>? stickers;

  ///
  final EditorBackground? background;

  ///
  final List<GradientBackground>? backgrounds;

  ///
  final List<Gradient>? gradients;

  ///
  final int fixedTabSize;

  ///
  final List<Color> colors;
}

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

final stickers = {'ARTS': _arts, 'EMOJIS': _gifs, 'SHAPES': _shapes};

///
const _gifs = {
  ImageSticker(
    name: 'No Way',
    path: 'https://media.giphy.com/media/USUIWSteF8DJoc5Snd/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Sad Face',
    path: 'https://media.giphy.com/media/h4OGa0npayrJX2NRPT/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Angry Face',
    path: 'https://media.giphy.com/media/j5E5qvtLDTfmHbT84Y/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Sad Miss You',
    path: 'https://media.giphy.com/media/IzcFv6WJ4310bDeGjo/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Angry Face',
    path: 'https://media.giphy.com/media/kyQfR7MlQQ9Gb8URKG/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Smiley Face Love',
    path: 'https://media.giphy.com/media/hof5uMY0nBwxyjY9S2/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Sad Face',
    path: 'https://media.giphy.com/media/kfS15Gnvf9UhkwafJn/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Crying',
    path: 'https://media.giphy.com/media/ViHbdDMcIOeLeblrbq/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Wow',
    path: 'https://media.giphy.com/media/XEyXIfu7IRQivZl1Mw/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Fuckboy',
    path: 'https://media.giphy.com/media/Kd5vjqlBqOhLsu3Rna/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Bless You',
    path: 'https://media.giphy.com/media/WqR7WfQVrpXNcmrm81/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'As If Whatever',
    path: 'https://media.giphy.com/media/Q6xFPLfzfsgKoKDV60/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Sick face',
    path: 'https://media.giphy.com/media/W3CLbW0KY3RtjsqtYO/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Birthday cake',
    path: 'https://media.giphy.com/media/l4RS2PG61HIYiukdoT/giphy.gif',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Embarrassed Face',
    path: 'https://media.giphy.com/media/kyzzHEoaLAAr9nX4fy/giphy.gif',
    pathType: PathType.networkImg,
  ),
};

///
const _arts = {
  ImageSticker(
    name: 'Smoke',
    path:
        'https://pngimage.net/wp-content/uploads/2018/06/%D1%87%D0%B5%D1%80%D0%BD%D1%8B%D0%B9-%D0%B4%D1%8B%D0%BC-png-2.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Multiple circles',
    path:
        'https://static.vecteezy.com/system/resources/previews/001/192/216/original/circle-png.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Eagle Wings',
    path: 'https://www.freeiconspng.com/uploads/angel-png-1.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Hair',
    path:
        'https://cdn.statically.io/img/kreditings.com/wp-content/uploads/2020/09/hair-png.png?quality=100&f=auto',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Cloud',
    path:
        'https://i.pinimg.com/originals/19/8d/ae/198daeda14097d45e417e62ff283f10e.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Abstract art',
    path:
        'https://freepngimg.com/download/graphic/53280-2-abstract-art-hd-free-png-hq.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Hair',
    path:
        'https://i.pinimg.com/originals/df/8b/f1/df8bf1a18047ff20d3f82e0f47dbe683.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    path: 'https://freepngimg.com/thumb/hair/21-women-hair-png-image-thumb.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Paint splatter',
    path:
        'https://pngimage.net/wp-content/uploads/2018/06/paint-splatter-png-6.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Hair',
    path: 'https://pngimg.com/uploads/hair/hair_PNG5637.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Hair',
    path: 'https://www.pngarts.com/files/4/Picsart-PNG-Background-Image.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Eagle',
    path:
        'https://www.pngkey.com/png/full/0-9646_american-eagle-logo-png-eagle-holding-lombardi-trophy.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Hair',
    path:
        'https://i.dlpng.com/static/png/1357097-cb-hair-png-hair-png-521_500_preview.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Art',
    path: 'https://i.dlpng.com/static/png/6719469_preview.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Bird',
    path:
        'https://storage.needpix.com/rsynced_images/no-background-2997564_1280.png',
    pathType: PathType.networkImg,
  ),
  ImageSticker(
    name: 'Eagle',
    path:
        'https://cdn.pixabay.com/photo/2017/12/13/23/27/no-background-3017971_1280.png',
    pathType: PathType.networkImg,
  ),
};

///
final _shapes = ShapeIcons.values
    .map((iconData) => IconSticker(iconData: iconData))
    .toSet();
