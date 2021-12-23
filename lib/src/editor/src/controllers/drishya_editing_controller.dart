import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Drishya editing controller
class DrishyaEditingController extends ValueNotifier<EditorValue> {
  ///
  DrishyaEditingController({
    EditorSetting setting = const EditorSetting(),
  })  : assert(
          setting.backgrounds.isNotEmpty,
          'Editor backgrounds cannot be empty!',
        ),
        assert(
          setting.colors.isNotEmpty,
          'Editor colors cannot be empty!',
        ),
        _setting = setting,
        _editorKey = GlobalKey(),
        _stickerController = StickerController(),
        _textController = TextEditingController(),
        _focusNode = FocusNode(),
        _currentAsset = ValueNotifier(null),
        super(
          EditorValue(
            color: setting.colors.first,
            background: setting.backgrounds.first,
          ),
        ) {
    _colorNotifier = ValueNotifier(_setting.colors.first);
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

  /// Editor textfield focus node
  late final FocusNode _focusNode;

  ///
  late final ValueNotifier<StickerAsset?> _currentAsset;

  /// Editor key
  GlobalKey get editorKey => _editorKey;

  /// Color picker notifier
  ValueNotifier<Color> get colorNotifier => _colorNotifier;

  /// Sticker controller
  StickerController get stickerController => _stickerController;

  /// Editor text field controller
  TextEditingController get textController => _textController;

  /// Editor text field focus node
  FocusNode get focusNode => _focusNode;

  /// Editor settings
  EditorSetting get setting => _setting;

  ///
  @internal
  ValueNotifier<StickerAsset?> get currentAsset => _currentAsset;

  var _isDisposed = false;

  @override
  set value(EditorValue newValue) {
    if (_isDisposed) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _colorNotifier.dispose();
    _textController.dispose();
    _stickerController.dispose();
    _focusNode.dispose();
    _currentAsset.dispose();
    _isDisposed = true;
    super.dispose();
  }

  /// Update editor value
  @internal
  void updateValue({
    bool? keyboardVisible,
    bool? fillTextfield,
    Color? textColor,
    int? maxLines,
    TextAlign? textAlign,
    bool? hasFocus,
    bool? editingMode,
    bool? hasStickers,
    bool? isEditing,
    bool? isStickerPickerOpen,
    bool? isColorPickerOpen,
    EditorBackground? background,
  }) {
    final oldValue = value;
    if (oldValue.hasFocus && !(hasFocus ?? false)) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    value = value.copyWith(
      keyboardVisible: keyboardVisible,
      fillTextfield: fillTextfield,
      color: textColor,
      maxLines: maxLines,
      textAlign: textAlign,
      hasFocus: hasFocus,
      editingMode: editingMode,
      hasStickers: hasStickers,
      isEditing: isEditing,
      isStickerPickerOpen: isStickerPickerOpen,
      isColorPickerOpen: isColorPickerOpen,
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
