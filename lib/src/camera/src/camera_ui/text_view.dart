import 'package:drishya_picker/src/camera/src/camera_ui/widgets/gradient_background.dart';
import 'package:drishya_picker/src/draggable_resizable/src/controller/stickerbooth_controller.dart';
import 'package:drishya_picker/src/draggable_resizable/src/controller/stickerbooth_value.dart';
import 'package:drishya_picker/src/draggable_resizable/src/draggable_resizable.dart';
import 'package:drishya_picker/src/draggable_resizable/src/entities/photo_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _initialStickerScale = 0.25;
const _minStickerScale = 0.05;

///
class TextView extends StatefulWidget {
  ///
  const TextView({
    Key? key,
  }) : super(key: key);

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  final _key = GlobalKey();

  late final StickerboothController controller;

  @override
  void initState() {
    super.initState();
    controller = StickerboothController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background
          const GradientBackground(),

          _Stickers(controller: controller),

          // Align(
          //   alignment: Alignment.topCenter,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       controller.addSticker(Asset(
          //         name: 'Demo',
          //         path: 'https://img.icons8.com/color/480/dart.png',
          //         size: Size(100.0, 100.0),
          //       ));
          //     },
          //     child: Icon(Icons.add),
          //   ),
          // ),

          //
        ],
      ),
    );
  }
}

extension on PhotoAsset {
  BoxConstraints getImageConstraints() {
    return BoxConstraints(
      minWidth: asset.size.width * _minStickerScale,
      minHeight: asset.size.height * _minStickerScale,
      maxWidth: double.infinity,
      maxHeight: double.infinity,
    );
  }
}

class _Stickers extends StatelessWidget {
  const _Stickers({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final StickerboothController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StickerboothValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.stickers.isEmpty) return const SizedBox();
        return Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: controller.outsideTapped,
                    ),
                  ),
                  for (final sticker in value.stickers)
                    DraggableResizable(
                      canTransform: sticker.id == value.selectedAssetId,
                      onUpdate: (update) => controller.dragSticker(
                        sticker: sticker,
                        update: update,
                      ),
                      onDelete: controller.deleteSticker,
                      size: sticker.asset.size,
                      constraints: sticker.getImageConstraints(),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          color: Colors.red,
                        ),
                        // child: Image.network(
                        //   sticker.asset.path,
                        //   fit: BoxFit.fill,
                        //   gaplessPlayback: true,
                        // ),
                      ),
                    ),

                  //
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

///
// Future<void> capturePng() async {
//   final boundary =
//       _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

//   if (boundary != null) {
//     final image = await boundary.toImage();

//     final date = DateTime.now();

//     final entity = AssetEntity(
//       id: date.millisecond.toString(),
//       height: image.height,
//       width: image.width,
//       typeInt: 1,
//       mimeType: 'image/png',
//       createDtSecond: date.second,
//       modifiedDateSecond: date.second,
//     );

//     log('$entity');

//     // final  byteData =
//     //     await image.toByteData(format: ui.ImageByteFormat.png);
//     // final Uint8List pngBytes = byteData!.buffer.asUint8List();
//     // print(pngBytes);
//   }
// }
