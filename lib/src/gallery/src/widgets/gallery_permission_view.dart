import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class GalleryPermissionView extends StatefulWidget {
  ///
  const GalleryPermissionView({
    Key? key,
    this.onRefresh,
  }) : super(key: key);

  ///
  final VoidCallback? onRefresh;

  @override
  State<GalleryPermissionView> createState() => _GalleryPermissionViewState();
}

class _GalleryPermissionViewState extends State<GalleryPermissionView>
    with WidgetsBindingObserver {
  var _setting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
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
    WidgetsBinding.instance?.removeObserver(this);
    _setting = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heading
          const Text(
            'Access Your Album',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          const Text(
            'Allow Drishya picker to access your album for picking media.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Allow access button
          TextButton(
            onPressed: () {
              PhotoManager.openSetting();
              _setting = true;
            },
            child: const Text('Allow Access'),
          ),
        ],
      ),
    );
  }
}
