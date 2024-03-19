import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
typedef StringGetter = String Function({bool isCamera});

///
class PermissionDelegate {
  ///
  const PermissionDelegate({String? appName})
      : appName = appName ?? 'Drishya Picker';

  ///
  final String appName;

  ///
  String titleString({
    required bool isCamera,
    required bool hasLimitedAccess,
  }) {
    if (!isCamera && hasLimitedAccess) return 'Limited Access';
    return 'Access Your ${isCamera ? 'Camera' : 'Album'}';
  }

  ///
  String descriptionString({
    required bool isCamera,
    required bool hasLimitedAccess,
  }) {
    if (!isCamera && hasLimitedAccess) {
      return '$appName has been granted limited access, allow full permission to access media.';
    }
    return '''Allow $appName to access your ${isCamera ? 'camera and microphone' : 'album for picking media'}.''';
  }

  ///
  Widget buildTitle({
    required bool isCamera,
    required bool hasLimitedAccess,
  }) {
    return Text(
      titleString(isCamera: isCamera, hasLimitedAccess: hasLimitedAccess),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }

  ///
  Widget buildDescription({
    required bool isCamera,
    required bool hasLimitedAccess,
  }) {
    return Text(
      descriptionString(isCamera: isCamera, hasLimitedAccess: hasLimitedAccess),
      textAlign: TextAlign.center,
    );
  }
}

///
class DefaultPermissionDelegate extends PermissionDelegate {
  ///
  const DefaultPermissionDelegate();
}

///
class PermissionView extends StatefulWidget {
  ///
  const PermissionView({
    super.key,
    this.onRefresh,
    PermissionDelegate? delegate,
    this.isCamera = false,
    this.cameraErrorCode,
    this.hasLimitedAccess = false,
  }) : delegate = delegate ?? const DefaultPermissionDelegate();

  ///
  final VoidCallback? onRefresh;

  ///
  final PermissionDelegate delegate;

  ///
  final bool isCamera;

  ///
  final String? cameraErrorCode;

  ///
  final bool hasLimitedAccess;

  @override
  State<PermissionView> createState() => _PermissionViewState();
}

class _PermissionViewState extends State<PermissionView>
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
          widget.delegate.buildTitle(
            isCamera: widget.isCamera,
            hasLimitedAccess: widget.hasLimitedAccess,
          ),

          const SizedBox(height: 24),

          // Description
          widget.delegate.buildDescription(
            isCamera: widget.isCamera,
            hasLimitedAccess: widget.hasLimitedAccess,
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
                      foregroundColor: scheme.secondary,
                      visualDensity: VisualDensity.comfortable,
                    ),
                    child: const Text('Deny Access'),
                  ),
                ),
              OutlinedButton(
                onPressed: () {
                  PhotoManager.openSetting();
                  _setting = true;
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onPrimary,
                  visualDensity: VisualDensity.comfortable,
                  backgroundColor: scheme.primary,
                ),
                child: const Text('Allow Access'),
              ),
            ],
          ),

          //
        ],
      ),
    );
  }
}
