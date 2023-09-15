import 'package:drishya_picker/src/camera/src/entities/singleton.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class GalleryPermissionView extends StatefulWidget {
  ///
  const GalleryPermissionView({
    Key? key,
    this.onRefresh,
    this.isCamera = false,
  }) : super(key: key);

  ///
  final VoidCallback? onRefresh;

  ///
  final bool isCamera;

  @override
  State<GalleryPermissionView> createState() => _GalleryPermissionViewState();
}

class _GalleryPermissionViewState extends State<GalleryPermissionView>
    with WidgetsBindingObserver {
  var _setting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _setting) {
      widget.onRefresh?.call();
      _setting = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setting = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      margin:
          widget.isCamera ? const EdgeInsets.symmetric(horizontal: 32) : null,
      decoration: BoxDecoration(
        borderRadius: widget.isCamera ? BorderRadius.circular(12) : null,
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heading
          Text(
            Singleton.textDelegate.accessYour +
                (widget.isCamera
                    ? Singleton.textDelegate.camera
                    : Singleton.textDelegate.album),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            Singleton.textDelegate.allowPermission +
                (widget.isCamera
                    ? Singleton.textDelegate.cameraAndMicrophone
                    : Singleton.textDelegate.albumForMedia),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Allow access button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isCamera)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: Navigator.of(context).pop,
                    style: OutlinedButton.styleFrom(
                      primary: scheme.secondary,
                      visualDensity: VisualDensity.comfortable,
                    ),
                    child: Text(Singleton.textDelegate.denyAccess),
                  ),
                ),
              OutlinedButton(
                onPressed: () {
                  PhotoManager.openSetting();
                  _setting = true;
                },
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.comfortable,
                  backgroundColor: scheme.primary,
                  primary: scheme.onPrimary,
                ),
                child: Text(Singleton.textDelegate.allowAccess),
              ),
            ],
          ),

          //
        ],
      ),
    );
  }
}
