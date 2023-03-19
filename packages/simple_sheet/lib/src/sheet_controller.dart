import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _kWidth = 304;
const double _kEdgeDragWidth = 20;
const double _kMinFlingVelocity = 365;
const Duration _kBaseSettleDuration = Duration(milliseconds: 246);

class _SSControllerScope extends InheritedWidget {
  const _SSControllerScope({
    required this.controller,
    required super.child,
  });

  final SSController controller;

  @override
  bool updateShouldNotify(_SSControllerScope old) {
    return controller != old.controller;
  }
}

/// Provides interactive behavior for [Drawer] widgets.
///
/// Rarely used directly. Drawer controllers are typically created automatically
/// by [Scaffold] widgets.
///
/// The drawer controller provides the ability to open and close a drawer, either
/// via an animation or via user interaction. When closed, the drawer collapses
/// to a translucent gesture detector that can be used to listen for edge
/// swipes.
///
/// See also:
///
///  * [Drawer], a container with the default width of a drawer.
///  * [Scaffold.drawer], the [Scaffold] slot for showing a drawer.
class SSController extends StatefulWidget {
  /// Creates a controller for a [Drawer].
  ///
  /// Rarely used directly.
  ///
  /// The [child] argument must not be null and is typically a [Drawer].
  const SSController({
    GlobalKey? key,
    required this.child,
    required this.alignment,
    this.isDrawerOpen = false,
    this.drawerCallback,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrimColor,
    this.edgeDragWidth,
    this.enableOpenDragGesture = true,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Drawer].
  final Widget child;

  /// The alignment of the [Drawer].
  ///
  /// This controls the direction in which the user should swipe to open and
  /// close the drawer.
  final DrawerAlignment alignment;

  /// Optional callback that is called when a [Drawer] is opened or closed.
  final DrawerCallback? drawerCallback;

  /// {@template flutter.material.DrawerController.dragStartBehavior}
  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag behavior used for opening
  /// and closing a drawer will begin at the position where the drag gesture won
  /// the arena. If set to [DragStartBehavior.down] it will begin at the position
  /// where a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  ///
  /// {@endtemplate}
  final DragStartBehavior dragStartBehavior;

  /// The color to use for the scrim that obscures the underlying content while
  /// a drawer is open.
  ///
  /// If this is null, then [DrawerThemeData.scrimColor] is used. If that
  /// is also null, then it defaults to [Colors.black54].
  final Color? scrimColor;

  /// Determines if the [Drawer] can be opened with a drag gesture.
  ///
  /// By default, the drag gesture is enabled.
  final bool enableOpenDragGesture;

  /// The width of the area within which a horizontal swipe will open the
  /// drawer.
  ///
  /// By default, the value used is 20.0 added to the padding edge of
  /// `MediaQuery.of(context).padding` that corresponds to [alignment].
  /// This ensures that the drag area for notched devices is not obscured. For
  /// example, if [alignment] is set to [DrawerAlignment.start] and
  /// `TextDirection.of(context)` is set to [TextDirection.ltr],
  /// 20.0 will be added to `MediaQuery.of(context).padding.left`.
  final double? edgeDragWidth;

  /// Whether or not the drawer is opened or closed.
  ///
  /// This parameter is primarily used by the state restoration framework
  /// to restore the drawer's animation controller to the open or closed state
  /// depending on what was last saved to the target platform before the
  /// application was killed.
  final bool isDrawerOpen;

  /// The closest instance of [SSController] that encloses the given
  /// context, or null if none is found.
  ///
  /// {@tool snippet} Typical usage is as follows:
  ///
  /// ```dart
  /// DrawerController? controller = DrawerController.maybeOf(context);
  /// ```
  /// {@end-tool}
  ///
  /// Calling this method will create a dependency on the closest
  /// [SSController] in the [context], if there is one.
  ///
  /// See also:
  ///
  /// * [SSController.of], which is similar to this method, but asserts
  ///   if no [SSController] ancestor is found.
  static SSController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SSControllerScope>()
        ?.controller;
  }

  /// The closest instance of [SSController] that encloses the given
  /// context.
  ///
  /// If no instance is found, this method will assert in debug mode and throw
  /// an exception in release mode.
  ///
  /// Calling this method will create a dependency on the closest
  /// [SSController] in the [context].
  ///
  /// {@tool snippet} Typical usage is as follows:
  ///
  /// ```dart
  /// DrawerController controller = DrawerController.of(context);
  /// ```
  /// {@end-tool}
  static SSController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(
      () {
        if (controller == null) {
          throw FlutterError(
            'DrawerController.of() was called with a context that does not '
            'contain a DrawerController widget.\n'
            'No DrawerController widget ancestor could be found starting from '
            'the context that was passed to DrawerController.of(). This can '
            'happen because you are using a widget that looks for a DrawerController '
            'ancestor, but no such ancestor exists.\n'
            'The context used was:\n'
            '  $context',
          );
        }
        return true;
      }(),
      '',
    );
    return controller!;
  }

  @override
  SSControllerState createState() => SSControllerState();
}

/// State for a [SSController].
///
/// Typically used by a [Scaffold] to [open] and [close] the drawer.
class SSControllerState extends State<SSController>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.isDrawerOpen ? 1.0 : 0.0,
      duration: _kBaseSettleDuration,
      vsync: this,
    );
    _controller
      ..addListener(_animationChanged)
      ..addStatusListener(_animationStatusChanged);
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrimColorTween = _buildScrimColorTween();
  }

  @override
  void didUpdateWidget(SSController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrimColor != oldWidget.scrimColor) {
      _scrimColorTween = _buildScrimColorTween();
    }
    if (widget.isDrawerOpen != oldWidget.isDrawerOpen) {
      switch (_controller.status) {
        case AnimationStatus.completed:
        case AnimationStatus.dismissed:
          _controller.value = widget.isDrawerOpen ? 1.0 : 0.0;
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    }
  }

  void _animationChanged() {
    setState(() {
      // The animation controller's state is our build state, and it changed already.
    });
  }

  LocalHistoryEntry? _historyEntry;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(
          onRemove: _handleHistoryEntryRemoved,
          impliesAppBarDismissal: false,
        );
        route.addLocalHistoryEntry(_historyEntry!);
        FocusScope.of(context).setFirstFocus(_focusScopeNode);
      }
    }
  }

  void _animationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        _ensureHistoryEntry();
        break;
      case AnimationStatus.reverse:
        _historyEntry?.remove();
        _historyEntry = null;
        break;
      case AnimationStatus.dismissed:
        break;
      case AnimationStatus.completed:
        break;
    }
  }

  void _handleHistoryEntryRemoved() {
    _historyEntry = null;
    close();
  }

  late AnimationController _controller;

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
    _ensureHistoryEntry();
  }

  void _handleDragCancel() {
    if (_controller.isDismissed || _controller.isAnimating) {
      return;
    }
    if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  final GlobalKey _drawerKey = GlobalKey();

  double get _width {
    final box = _drawerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      return box.size.width;
    }
    return _kWidth; // drawer not being shown currently
  }

  bool _previouslyOpened = false;

  void _move(DragUpdateDetails details) {
    var delta = details.primaryDelta! / _width;
    switch (widget.alignment) {
      case DrawerAlignment.start:
        break;
      case DrawerAlignment.end:
        delta = -delta;
        break;
    }
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        _controller.value -= delta;
        break;
      case TextDirection.ltr:
        _controller.value += delta;
        break;
    }

    final opened = _controller.value > 0.5;
    if (opened != _previouslyOpened && widget.drawerCallback != null) {
      widget.drawerCallback!(opened);
    }
    _previouslyOpened = opened;
  }

  void _settle(DragEndDetails details) {
    if (_controller.isDismissed) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      var visualVelocity = details.velocity.pixelsPerSecond.dx / _width;
      switch (widget.alignment) {
        case DrawerAlignment.start:
          break;
        case DrawerAlignment.end:
          visualVelocity = -visualVelocity;
          break;
      }
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          _controller.fling(velocity: -visualVelocity);
          widget.drawerCallback?.call(visualVelocity < 0.0);
          break;
        case TextDirection.ltr:
          _controller.fling(velocity: visualVelocity);
          widget.drawerCallback?.call(visualVelocity > 0.0);
          break;
      }
    } else if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  /// Starts an animation to open the drawer.
  ///
  /// Typically called by [ScaffoldState.openDrawer].
  void open() {
    _controller.fling();
    widget.drawerCallback?.call(true);
  }

  /// Starts an animation to close the drawer.
  void close() {
    _controller.fling(velocity: -1);
    widget.drawerCallback?.call(false);
  }

  late ColorTween _scrimColorTween;
  final GlobalKey _gestureDetectorKey = GlobalKey();

  ColorTween _buildScrimColorTween() {
    return ColorTween(
      begin: Colors.transparent,
      end: widget.scrimColor ??
          DrawerTheme.of(context).scrimColor ??
          Colors.black54,
    );
  }

  AlignmentDirectional get _drawerOuterAlignment {
    switch (widget.alignment) {
      case DrawerAlignment.start:
        return AlignmentDirectional.centerStart;
      case DrawerAlignment.end:
        return AlignmentDirectional.centerEnd;
    }
  }

  AlignmentDirectional get _drawerInnerAlignment {
    switch (widget.alignment) {
      case DrawerAlignment.start:
        return AlignmentDirectional.centerEnd;
      case DrawerAlignment.end:
        return AlignmentDirectional.centerStart;
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final drawerIsStart = widget.alignment == DrawerAlignment.start;
    final padding = MediaQuery.of(context).padding;
    final textDirection = Directionality.of(context);
    final bool isDesktop;
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        isDesktop = false;
        break;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        isDesktop = true;
        break;
    }

    var dragAreaWidth = widget.edgeDragWidth;
    if (widget.edgeDragWidth == null) {
      switch (textDirection) {
        case TextDirection.ltr:
          dragAreaWidth =
              _kEdgeDragWidth + (drawerIsStart ? padding.left : padding.right);
          break;
        case TextDirection.rtl:
          dragAreaWidth =
              _kEdgeDragWidth + (drawerIsStart ? padding.right : padding.left);
          break;
      }
    }

    if (_controller.status == AnimationStatus.dismissed) {
      if (widget.enableOpenDragGesture && !isDesktop) {
        return Align(
          alignment: _drawerOuterAlignment,
          child: GestureDetector(
            key: _gestureDetectorKey,
            onVerticalDragUpdate: _move,
            onVerticalDragEnd: _settle,
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
            dragStartBehavior: widget.dragStartBehavior,
            child: Container(width: dragAreaWidth),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      final bool platformHasBackButton;
      switch (Theme.of(context).platform) {
        case TargetPlatform.android:
          platformHasBackButton = true;
          break;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          platformHasBackButton = false;
          break;
      }

      final Widget child = _SSControllerScope(
        controller: widget,
        child: RepaintBoundary(
          child: Stack(
            children: <Widget>[
              BlockSemantics(
                child: ExcludeSemantics(
                  // On Android, the back button is used to dismiss a modal.
                  excluding: platformHasBackButton,
                  child: GestureDetector(
                    onTap: close,
                    child: Semantics(
                      label: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      child: Container(
                        // The drawer's "scrim"
                        color: _scrimColorTween.evaluate(_controller),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: _drawerOuterAlignment,
                child: Align(
                  alignment: _drawerInnerAlignment,
                  heightFactor: _controller.value,
                  child: RepaintBoundary(
                    child: FocusScope(
                      key: _drawerKey,
                      node: _focusScopeNode,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (isDesktop) {
        return child;
      }

      return GestureDetector(
        key: _gestureDetectorKey,
        onVerticalDragDown: _handleDragDown,
        onVerticalDragUpdate: _move,
        onVerticalDragEnd: _settle,
        onVerticalDragCancel: _handleDragCancel,
        excludeFromSemantics: true,
        dragStartBehavior: widget.dragStartBehavior,
        child: child,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context), '');
    return ListTileTheme.merge(
      style: ListTileStyle.drawer,
      child: _buildDrawer(context),
    );
  }
}
