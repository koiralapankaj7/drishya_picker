import 'dart:developer';
import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:photo_manager/photo_manager.dart';

///
class PhotoEditingController extends ValueNotifier<PhotoValue> {
  ///
  PhotoEditingController() : super(PhotoValue());

  ///
  late GlobalKey _editorKey;

  ///
  late EditorSetting _setting;

  ///
  late ValueNotifier<Color> _colorNotifier;

  ///
  late StickerController _stickerController;

  ///
  late TextEditingController _textController;

  ///
  GlobalKey get editorKey => _editorKey;

  ///
  bool get hasStickers => !value.hasStickers;

  ///
  ValueNotifier<Color> get colorNotifier => _colorNotifier;

  /// Editor sticker controller
  StickerController get stickerController => _stickerController;

  /// Editor text editing controller
  TextEditingController get textController => _textController;

  /// Photo editing settings
  EditorSetting get setting => _setting;

  //
  var _init = false;

  /// Initialize photo editing controller properties
  @internal
  void init(BuildContext context, {EditorSetting? setting}) {
    _init = true;
    _setting = setting ?? EditorSetting();
    _editorKey = GlobalKey();
    _colorNotifier = ValueNotifier(_setting.colors.first);
    _stickerController = StickerController();
    _textController = TextEditingController();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (value.background == null) {
        changeBackground();
      }
    });
  }

  @override
  void dispose() {
    _colorNotifier.dispose();
    _stickerController.dispose();
    _textController.dispose();
    _init = false;
    super.dispose();
  }

  /// Update editor value
  void updateValue({
    bool? fillTextfield,
    Color? textColor,
    int? maxLines,
    TextAlign? textAlign,
    bool? hasFocus,
    bool? editingMode,
    bool? hasStickers,
    bool? isEditing,
    bool? isStickerPickerOpen,
    bool? isColorPickerVisible,
    EditorBackground? background,
  }) {
    if (!_init) return;

    if (!(hasFocus ?? false)) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    value = value.copyWith(
      fillTextfield: fillTextfield,
      textColor: textColor,
      maxLines: maxLines,
      textAlign: textAlign,
      hasFocus: hasFocus,
      editingMode: editingMode,
      hasStickers: hasStickers,
      isEditing: isEditing,
      isStickerPickerOpen: isStickerPickerOpen,
      isColorPickerVisible: isColorPickerVisible,
      background: background,
    );
  }

  /// Clear editor
  void clear() {
    if (!_init) return;
    _stickerController.clearStickers();
    value = value.copyWith(hasStickers: false);
  }

  /// Change editor background
  void changeBackground() {
    if (!_init) return;

    final current = value.background;

    if (current == null) {
      final bg = _setting.backgrounds.first;

      value = value.copyWith(
        background: bg,
        textColor:
            bg is GradientBackground ? bg.firstColor : _colorNotifier.value,
      );
      return;
    }

    final index = _setting.backgrounds.indexOf(current);

    final nextIndex =
        index >= 0 && index + 1 < _setting.backgrounds.length ? index + 1 : 0;
    final bg = _setting.backgrounds[nextIndex];
    value = value.copyWith(
      background: bg,
      textColor:
          bg is GradientBackground ? bg.firstColor : _colorNotifier.value,
    );

    // if (background is GradientBackground) {
    //   final current = value.background as GradientBackground;
    //   final index = _setting.gradients.indexOf(current);

    //   final nextIndex = (index + 1).clamp(0, setting.gradients.length - 1);
    //   // index >= 0 && index + 1 < setting.gradients.length ? index + 1 : 0;
    //   final bg = _setting.gradients[nextIndex];
    //   value = value.copyWith(background: bg, textBackground: bg);
    // } else {
    //   value = value.copyWith(background: background);
    // }
    // if (background != null && background is PhotoBackground) {
    //   value = value.copyWith(background: background);
    // } else {
    //   final current = value.background;
    //   final index = value.background is GradientBackground
    //       ? gradients.indexOf(current as GradientBackground)
    //       : 0;
    //   final hasMatch = index != -1;
    //   final nextIndex =
    //       hasMatch && index + 1 < gradients.length ? index + 1 : 0;
    //   final bg = gradients[nextIndex];
    //   value = value.copyWith(background: bg, textBackground: bg);
    // }
  }

  /// Take screen shot of the editor
  Future<DrishyaEntity?> completeEditing() async {
    if (!_init) return null;
    try {
      final bg = value.background;
      if (bg is PhotoBackground && bg.bytes != null && !value.hasStickers) {
        final entity = await PhotoManager.editor.saveImage(bg.bytes!);
        return entity?.toDrishya;
      } else {
        final boundary = _editorKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        final image = await boundary!.toImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final data = byteData!.buffer.asUint8List();
        final entity = await PhotoManager.editor.saveImage(data);
        return entity?.toDrishya;
      }
    } catch (e) {
      log('Exception occured while capturing picture : $e');
    }
  }

  //
}
