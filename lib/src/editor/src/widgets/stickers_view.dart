import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

const _minStickerScale = 1.0;

///
class StickersView extends StatefulWidget {
  ///
  const StickersView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PhotoEditingController controller;

  @override
  State<StickersView> createState() => _StickersViewState();
}

class _StickersViewState extends State<StickersView> {
  late final GlobalKey _deleteKey;
  late final PhotoEditingController _controller;
  var _collied = false;
  late final ValueNotifier<Color> _colorNotifier;

  @override
  void initState() {
    super.initState();
    _deleteKey = GlobalKey();
    _controller = widget.controller;
    _colorNotifier = ValueNotifier(_colors.first);
  }

  @override
  void dispose() {
    _colorNotifier.dispose();
    super.dispose();
  }

  void _onTapOutside() {
    _controller.stickerController.unselectSticker();
    if (_controller.value.colorPickerVisibility) {
      _controller.updateValue(colorPickerVisibility: false);
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final deleteBox =
        _deleteKey.currentContext?.findRenderObject() as RenderBox?;

    if (deleteBox != null) {
      final deleteSize = deleteBox.size;

      final deletePos = deleteBox.localToGlobal(Offset.zero);

      final stickerPos = details.focalPoint;

      final collide = deletePos.dx < stickerPos.dx &&
          deletePos.dx + deleteSize.width > stickerPos.dx &&
          deletePos.dy < stickerPos.dy &&
          deletePos.dy + deleteSize.height > stickerPos.dy;

      setState(() {
        _collied = collide;
      });
    }
  }

  Widget? _stickerChild(Sticker sticker) {
    if (sticker is ImageSticker && sticker.pathType == PathType.networkImg) {
      return Image.network(
        sticker.path,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    } else if (sticker is ImageSticker &&
        sticker.pathType == PathType.assetsImage) {
      return Image.asset(
        sticker.path,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    } else if (sticker is TextSticker) {
      return Container(
        constraints: BoxConstraints.loose(sticker.size),
        decoration: BoxDecoration(
          color: sticker.withBackground
              ? _controller.value.textBackground.colors.first
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FittedBox(
          child: Text(
            sticker.text,
            textAlign: sticker.textAlign,
            style: sticker.style,
          ),
        ),
      );
    } else if (sticker is IconSticker) {
      return _IconSticker(colorNotifier: _colorNotifier, sticker: sticker);
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stickerController = _controller.stickerController;

    return ValueListenableBuilder<StickerValue>(
      valueListenable: stickerController,
      builder: (context, stickerValue, child) {
        if (stickerValue.assets.isEmpty) {
          return const SizedBox();
        }

        return Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // For outside tap
              Positioned.fill(child: GestureDetector(onTap: _onTapOutside)),

              // Stickers
              Stack(
                fit: StackFit.expand,
                children: stickerValue.assets.map((asset) {
                  final isSelected = asset.id == stickerValue.selectedAssetId;

                  return DraggableResizable(
                    key: Key(asset.id),
                    canTransform: isSelected,
                    onTap: () {
                      asset.sticker.onPressed?.call(asset.sticker);
                      if (asset.sticker is TextSticker) {
                        stickerController.deleteSticker(asset);
                        _controller.updateValue(hasFocus: true);
                      } else if (asset.sticker is IconSticker) {
                        _controller.updateValue(colorPickerVisibility: true);
                      }
                    },
                    onStart: () {
                      _controller.updateValue(isEditing: true);
                    },
                    onEnd: () {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (_collied) {
                          stickerController.deleteSticker(asset);
                          _controller.updateValue(
                            hasStickers: stickerValue.assets.length > 1,
                          );
                          _collied = false;
                        }
                      });
                      _controller.updateValue(isEditing: false);
                    },
                    onUpdate: (update, key) {
                      stickerController.dragSticker(
                        asset: asset,
                        update: update,
                      );
                    },
                    onScaleUpdate: _onScaleUpdate,
                    size: asset.sticker.size,
                    constraints: asset.getImageConstraints(),
                    child: Opacity(
                      opacity: isSelected && _collied ? 0.3 : 1.0,
                      child: _stickerChild(asset.sticker),
                    ),
                  );
                }).toList(),
              ),

              // Delete popup area
              if (_controller.value.isEditing)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    key: _deleteKey,
                    duration: const Duration(milliseconds: 100),
                    height: _collied ? 60.0 : 48.0,
                    width: _collied ? 60.0 : 48.0,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black45,
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: _collied ? 36.0 : 30.0,
                    ),
                  ),
                ),

              // Color picker
              if (_controller.value.colorPickerVisibility &&
                  !_controller.value.isEditing)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _colors
                          .map(
                            (color) => _ColorCircle(
                              color: color,
                              colorNotifier: _colorNotifier,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),

              //
            ],
          ),
        );
      },
    );
  }
}

final _colors = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.yellow,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.orange,
];

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    Key? key,
    required this.color,
    required this.colorNotifier,
  }) : super(key: key);

  final Color color;
  final ValueNotifier<Color> colorNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: colorNotifier,
      builder: (context, c, child) {
        final isSelected = color == c;
        final size = isSelected ? 36.0 : 30.0;
        return InkWell(
          onTap: () {
            colorNotifier.value = color;
          },
          child: SizedBox(
            height: 40,
            width: 40,
            child: Align(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: size,
                width: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(size),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: CircleAvatar(backgroundColor: color),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IconSticker extends StatelessWidget {
  const _IconSticker({
    Key? key,
    required this.sticker,
    required this.colorNotifier,
  }) : super(key: key);

  final IconSticker sticker;
  final ValueNotifier<Color> colorNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: colorNotifier,
      builder: (context, color, child) {
        return FittedBox(
          child: Icon(
            sticker.iconData,
            color: color,
          ),
        );
      },
    );
  }
}

extension on StickerAsset {
  BoxConstraints getImageConstraints() {
    return BoxConstraints(
      minWidth: sticker.size.width * _minStickerScale,
      minHeight: sticker.size.height * _minStickerScale,
    );
  }
}
