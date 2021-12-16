import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Drishya editing controller
class DrishyaEditingController extends ValueNotifier<EditorValue> {
  ///
  DrishyaEditingController({
    EditorSetting? setting,
  })  : assert(
          setting == null || setting.backgrounds.isNotEmpty,
          'Editor backgrounds cannot be empty!',
        ),
        _setting = setting ?? const EditorSetting(),
        super(EditorValue()) {
    _editorKey = GlobalKey();
    _colorNotifier = ValueNotifier(_setting.colors.first);
    _stickerController = StickerController();
    _textController = TextEditingController();
  }

  ///
  late final GlobalKey _editorKey;

  ///
  late final EditorSetting _setting;

  ///
  late final ValueNotifier<Color> _colorNotifier;

  ///
  late final StickerController _stickerController;

  ///
  late final TextEditingController _textController;

  /// Editor key
  GlobalKey get editorKey => _editorKey;

  /// true, if editor has  stickers
  bool get hasStickers => !value.hasStickers;

  /// Color picker notifier
  ValueNotifier<Color> get colorNotifier => _colorNotifier;

  /// Sticker controller
  StickerController get stickerController => _stickerController;

  /// Editor text field controller
  TextEditingController get textController => _textController;

  /// Editor settings
  EditorSetting get setting => _setting;

  var _isDisposed = false;

  @override
  set value(EditorValue newValue) {
    if (_isDisposed) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _colorNotifier.dispose();
    _stickerController.dispose();
    _textController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  /// Update editor value
  @internal
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

  ///
  /// Clear editor
  ///
  void clear() {
    _stickerController.clearStickers();
    value = value.copyWith(hasStickers: false);
  }

  ///
  /// Change editor background
  ///
  void changeBackground() {
    final current = value.background;

    if (current == null) {
      final bg = _setting.backgrounds.first;
      updateValue(
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
    updateValue(
      background: bg,
      textColor:
          bg is GradientBackground ? bg.firstColor : _colorNotifier.value,
    );
  }

  ///
  /// Complete editing and generate image
  ///
  Future<DrishyaEntity?> completeEditing({
    ValueSetter<Exception>? onException,
  }) async {
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
      onException?.call(
        Exception('Exception occured while capturing picture : $e'),
      );
    }
  }

  //
}
