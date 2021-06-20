import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'camera_type.dart';

///
class CaptureButton extends StatelessWidget {
  ///
  const CaptureButton({
    Key? key,
    required this.onPressed,
    required this.cameraTypeNotifier,
  }) : super(key: key);

  ///
  final ValueNotifier<CameraType> cameraTypeNotifier;

  ///
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CameraTypeBuilder(
          notifier: cameraTypeNotifier,
          builder: (context, type, child) {
            return GestureDetector(
              onTap: onPressed,
              child: Container(
                height: 60.0,
                width: 60.0,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 3.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white60,
                  child: Builder(
                    builder: (context) {
                      switch (type) {
                        case CameraType.selfi:
                          return const Icon(CupertinoIcons.person_fill);
                        case CameraType.video:
                          return const Icon(Icons.circle);
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
