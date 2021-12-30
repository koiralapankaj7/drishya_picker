import 'package:drishya_picker/drishya_picker.dart';
import 'package:example/fullscreen_gallery.dart';
import 'package:example/recent_entities.dart';
import 'package:example/shape_icons.dart';
import 'package:example/text_field_view.dart';
import 'package:flutter/material.dart';

import 'grid_view_widget.dart';

///
class CollapsableGallery extends StatefulWidget {
  ///
  const CollapsableGallery({
    Key? key,
  }) : super(key: key);

  @override
  _CollapsableGalleryState createState() => _CollapsableGalleryState();
}

class _CollapsableGalleryState extends State<CollapsableGallery> {
  late final GalleryController _controller;
  late final ValueNotifier<Data> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(Data());
    _controller = GalleryController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidableGallery(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Slidable Gallery'),
        ),
        body: Column(
          children: [
            // Grid view
            Expanded(
              child: GridViewWidget(
                controller: _controller,
                setting: gallerySetting,
                notifier: _notifier,
              ),
            ),

            const SizedBox(height: 8.0),

            RecentEntities(controller: _controller, notifier: _notifier),

            const SizedBox(height: 8.0),

            // Textfield
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Textfield
                  Expanded(child: TextFieldView(notifier: _notifier)),

                  // Camera field..
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CameraViewField(
                      editorSetting: EditorSetting(
                        colors: _defaultBackgrounds
                            .map((e) => e.colors!)
                            .expand((e) => e)
                            .toList(),
                        stickers: _stickers1,
                      ),
                      photoEditorSetting: EditorSetting(
                        colors: _colors.skip(4).toList(),
                        stickers: _stickers3,
                      ),
                      onCapture: (entities) {
                        _notifier.value = _notifier.value.copyWith(
                          entities: [..._notifier.value.entities, ...entities],
                        );
                      },
                      child: const Icon(Icons.camera),
                    ),
                  ),

                  // Gallery field
                  ValueListenableBuilder<Data>(
                    valueListenable: _notifier,
                    builder: (context, data, child) {
                      return GalleryViewField(
                        setting: gallerySetting.copyWith(
                          maximumCount: data.maxLimit,
                          albumSubtitle: 'Image only',
                          requestType: data.requestType,
                          selectedEntities: data.entities,
                        ),
                        onChanged: (entity, remove) {
                          final entities = _notifier.value.entities.toList();
                          remove
                              ? entities.remove(entity)
                              : entities.add(entity);
                          _notifier.value =
                              _notifier.value.copyWith(entities: entities);
                        },
                        onSubmitted: (list) {
                          _notifier.value =
                              _notifier.value.copyWith(entities: list);
                        },
                        child: child,
                      );
                    },
                    child: const Icon(Icons.photo),
                  ),

                  //
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}

///
GallerySetting get gallerySetting => GallerySetting(
      enableCamera: true,
      maximumCount: 10,
      requestType: RequestType.all,
      editorSetting: EditorSetting(colors: _colors, stickers: _stickers1),
      cameraSetting: const CameraSetting(videoDuration: Duration(seconds: 15)),
      cameraTextEditorSetting: EditorSetting(
        backgrounds: _defaultBackgrounds,
        colors: _colors.take(4).toList(),
        stickers: _stickers2,
      ),
      cameraPhotoEditorSetting: EditorSetting(
        colors: _colors.skip(4).toList(),
        stickers: _stickers3,
      ),
    );

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
final _stickers1 = {'ARTS': _arts, 'EMOJIS': _gifs, 'SHAPES': _shapes};
final _stickers2 = {'EMOJIS': _gifs, 'SHAPES': _shapes};
final _stickers3 = {
  'SHAPES': _shapes,
  'SHAPES1': _shapes,
  'SHAPES2': _shapes,
  'SHAPES3': _shapes,
  'SHAPES4': _shapes,
  'SHAPES5': _shapes,
};

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
    .map(
      (iconData) => IconSticker(iconData: iconData),
    )
    .toSet();
