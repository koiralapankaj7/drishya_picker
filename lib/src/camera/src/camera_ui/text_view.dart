import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue.shade300,
              Colors.blue,
            ],
          ),
        ),
      ),
    );
  }

  ///
  Future<void> capturePng() async {
    final boundary =
        _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary != null) {
      final image = await boundary.toImage();

      final date = DateTime.now();

      final entity = AssetEntity(
        id: date.millisecond.toString(),
        height: image.height,
        width: image.width,
        typeInt: 1,
        mimeType: 'image/png',
        createDtSecond: date.second,
        modifiedDateSecond: date.second,
      );

      log('$entity');

      // final  byteData =
      //     await image.toByteData(format: ui.ImageByteFormat.png);
      // final Uint8List pngBytes = byteData!.buffer.asUint8List();
      // print(pngBytes);
    }
  }
}
