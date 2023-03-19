import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:simple_sheet/src/drag_gesture.dart';
import 'package:simple_sheet/src/sheet_controller.dart';

const FloatingActionButtonLocation _kDefaultFloatingActionButtonLocation =
    FloatingActionButtonLocation.endFloat;
const FloatingActionButtonAnimator _kDefaultFloatingActionButtonAnimator =
    FloatingActionButtonAnimator.scaling;

const Curve _standardBottomSheetCurve = standardEasing;
// When the top of the BottomSheet crosses this threshold, it will start to
// shrink the FAB and show a scrim.
const double _kBottomSheetDominatesPercentage = 0.3;
const double _kMinBottomSheetScrimOpacity = 0.1;
const double _kMaxBottomSheetScrimOpacity = 0.6;

// =============================================================================
///
class SimpleSheetScaffold extends StatefulWidget {
  ///
  const SimpleSheetScaffold({
    required this.child,
    super.key,
  });

  ///
  final Widget child;

  /// Finds the [ScaffoldState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will cause an
  /// assert in debug mode, and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// {@tool dartpad}
  /// Typical usage of the [Scaffold.of] function is to call it from within the
  /// `build` method of a child of a [Scaffold].
  ///
  /// ** See code in examples/api/lib/material/scaffold/scaffold.of.0.dart **
  /// {@end-tool}
  ///
  /// {@tool dartpad}
  /// When the [Scaffold] is actually created in the same `build` function, the
  /// `context` argument to the `build` function can't be used to find the
  /// [Scaffold] (since it's "above" the widget being returned in the widget
  /// tree). In such cases, the following technique with a [Builder] can be used
  /// to provide a new scope with a [BuildContext] that is "under" the
  /// [Scaffold]:
  ///
  /// ** See code in examples/api/lib/material/scaffold/scaffold.of.1.dart **
  /// {@end-tool}
  ///
  /// A more efficient solution is to split your build function into several
  /// widgets. This introduces a new context from which you can obtain the
  /// [Scaffold]. In this solution, you would have an outer widget that creates
  /// the [Scaffold] populated by instances of your new inner widgets, and then
  /// in these inner widgets you would use [Scaffold.of].
  ///
  /// A less elegant but more expedient solution is assign a [GlobalKey] to the
  /// [Scaffold], then use the `key.currentState` property to obtain the
  /// [ScaffoldState] rather than using the [Scaffold.of] function.
  ///
  /// If there is no [Scaffold] in scope, then this will throw an exception.
  /// To return null if there is no [Scaffold], use [maybeOf] instead.
  static SimpleSheetScaffoldState of(BuildContext context) {
    final result = context.findAncestorStateOfType<SimpleSheetScaffoldState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'SimpleSheetScaffoldState.of() called with a context that does not contain a SimpleSheetScaffoldState.',
      ),
      ErrorDescription(
        'No Scaffold ancestor could be found starting from the context that was passed to Scaffold.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the Scaffold widget being sought.',
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
        'context that is "under" the Scaffold. For an example of this, please see the '
        'documentation for Scaffold.of():\n'
        '  https://api.flutter.dev/flutter/material/Scaffold/of.html',
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into several widgets. This '
        'introduces a new context from which you can obtain the Scaffold. In this solution, '
        'you would have an outer widget that creates the Scaffold populated by instances of '
        'your new inner widgets, and then in these inner widgets you would use Scaffold.of().\n'
        'A less elegant but more expedient solution is assign a GlobalKey to the Scaffold, '
        'then use the key.currentState property to obtain the ScaffoldState rather than '
        'using the Scaffold.of() function.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Finds the [ScaffoldState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function to this one that throws if no instance
  ///    encloses the given context. Also includes some sample code in its
  ///    documentation.
  static SimpleSheetScaffoldState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SimpleSheetScaffoldState>();
  }

  @override
  State<SimpleSheetScaffold> createState() => SimpleSheetScaffoldState();
}

///
class SimpleSheetScaffoldState extends State<SimpleSheetScaffold>
    with TickerProviderStateMixin {
  // late final GalleryController _controller;
  // late final PanelController _panelController;
  late AnimationController _controller;
  Widget? _currentBottomSheet;

  final GlobalKey<SSControllerState> _sheetKey = GlobalKey<SSControllerState>();

  ///
  bool get isSheetOpen => _currentBottomSheet != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // value: 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  // ///
  // void closeSheet() {
  //   _sheetKey.currentState?.close();
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // No need to init controller from here, [GalleryView] will do that for us.
  //   _controller = widget.controller ?? GalleryController();
  //   _panelController = _controller.panelController;
  // }

  @override
  void dispose() {
    // if (widget.controller == null) {
    //   _controller.dispose();
    // }
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBottomSheet<T>(
    WidgetBuilder builder, {
    // required AnimationController animationController,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool? enableDrag,
    bool shouldDisposeAnimationController = true,
  }) {
    // assert(() {
    //   if (widget.bottomSheet != null &&
    //       isPersistent &&
    //       _currentBottomSheet != null) {
    //     throw FlutterError(
    //       'Scaffold.bottomSheet cannot be specified while a bottom sheet '
    //       'displayed with showBottomSheet() is still visible.\n'
    //       'Rebuild the Scaffold with a null bottomSheet before calling showBottomSheet().',
    //     );
    //   }
    //   return true;
    // }());

    final completer = Completer<T>();
    final bottomSheetKey = GlobalKey<_StandardBottomSheetState>();
    late _StandardBottomSheet bottomSheet;

    var removedEntry = false;
    var doingDispose = false;

    // void removePersistentSheetHistoryEntryIfNeeded() {
    //   assert(isPersistent);
    //   if (_persistentSheetHistoryEntry != null) {
    //     _persistentSheetHistoryEntry!.remove();
    //     _persistentSheetHistoryEntry = null;
    //   }
    // }

    void removeCurrentBottomSheet() {
      removedEntry = true;
      if (_currentBottomSheet == null) {
        return;
      }
      // assert(_currentBottomSheet!._widget == bottomSheet);
      // assert(bottomSheetKey.currentState != null);
      // _showFloatingActionButton();

      // if (isPersistent) {
      //   removePersistentSheetHistoryEntryIfNeeded();
      // }

      bottomSheetKey.currentState!.close();

      // if (animationController.status != AnimationStatus.dismissed) {
      //   _dismissedBottomSheets.add(bottomSheet);
      // }
      completer.complete();
    }

    final entry = LocalHistoryEntry(
      onRemove: () {
        if (!removedEntry &&
            // _currentBottomSheet?._widget == bottomSheet
            //  &&
            !doingDispose) {
          removeCurrentBottomSheet();
        }
      },
    );

    void removeEntryIfNeeded() {
      if (!removedEntry) {
        entry.remove();
        removedEntry = true;
      }
    }

    bottomSheet = _StandardBottomSheet(
      key: bottomSheetKey,
      // animationController: animationController,
      animationController: _controller,
      enableDrag: enableDrag ?? true,
      onClosing: () {
        if (_currentBottomSheet == null) {
          return;
        }
        // assert(_currentBottomSheet!._widget == bottomSheet);
        removeEntryIfNeeded();
      },
      onDismissed: () {
        // if (_dismissedBottomSheets.contains(bottomSheet)) {
        //   setState(() {
        //     _dismissedBottomSheets.remove(bottomSheet);
        //   });
        // }
        setState(() {
          _currentBottomSheet = null;
        });
      },
      onDispose: () {
        doingDispose = true;
        removeEntryIfNeeded();
        if (_currentBottomSheet != null) {
          setState(() {
            _currentBottomSheet = null;
          });
        }
        // if (shouldDisposeAnimationController) {
        //   animationController.dispose();
        // }
      },
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
    );

    ///
    ModalRoute.of(context)!.addLocalHistoryEntry(entry);

    // return PersistentBottomSheetController<T>._(
    //   bottomSheet,
    //   completer,
    //   entry != null ? entry.remove : removeCurrentBottomSheet,
    //   (VoidCallback fn) {
    //     bottomSheetKey.currentState?.setState(fn);
    //   },
    //   !isPersistent,
    // );

    return bottomSheet;
  }

  ///
  void showBottomSheet<T>(
    WidgetBuilder builder, {
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool? enableDrag,
    AnimationController? transitionAnimationController,
  }) {
    assert(debugCheckHasSimpleSheetScaffold(context), '');

    // _closeCurrentBottomSheet();
    // final controller = (transitionAnimationController ??
    //     BottomSheet.createAnimationController(this))
    //   ..forward();
    if (_currentBottomSheet != null) {
      Navigator.of(context).pop();
      return;
    }
    // _controller.animateTo(
    //   0.45,
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.fastLinearToSlowEaseIn,
    // );
    _snapToPosition(0.45);

    setState(() {
      _currentBottomSheet = _buildBottomSheet<T>(
        builder,
        // animationController: controller,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        enableDrag: enableDrag,
        shouldDisposeAnimationController: transitionAnimationController == null,
      );
    });
    // return _currentBottomSheet! as PersistentBottomSheetController<T>;

    // _sheetKey.currentState?.open();
    // if (_bottomSheet != null) return;
    // setState(() {
    //   _bottomSheet = builder(context);
    // });
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 600,
        ratio: 1.1,
      ),
      startValue ?? _controller.value,
      endValue,
      0,
    );
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // color: Colors.amber,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // log('Progress is => ${_controller.value}');
          return Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: _DismissSheetAction(context),
            },
            child: CustomMultiChildLayout(
              delegate: _ScaffoldLayout(
                progress: _controller.value,
              ),
              children: <LayoutId>[
                LayoutId(
                  id: 'SimpleSheet.body',
                  child: _BodyBuilder(
                    body: widget.child,
                  ),
                ),
                if (_currentBottomSheet != null)
                  LayoutId(
                    id: 'SimpleSheet.sheet',
                    child: _currentBottomSheet!,
                    // child: SSController(
                    //   key: _sheetKey,
                    //   alignment: DrawerAlignment.start,
                    //   drawerCallback: (isOpened) {
                    //     if (isOpened) {}
                    //   },
                    //   child: _currentBottomSheet!,
                    // ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================

///
// PersistentBottomSheetController<T> showSimpleSheet<T>({
//   required BuildContext context,
//   required WidgetBuilder builder,
//   Color? backgroundColor,
//   double? elevation,
//   ShapeBorder? shape,
//   Clip? clipBehavior,
//   BoxConstraints? constraints,
//   bool? enableDrag,
//   AnimationController? transitionAnimationController,
// }) {
//   assert(debugCheckHasSimpleSheetScaffold(context), '');

//   return Scaffold.of(context).showBottomSheet<T>(
//     builder,
//     backgroundColor: backgroundColor,
//     elevation: elevation,
//     shape: shape,
//     clipBehavior: clipBehavior,
//     constraints: constraints,
//     enableDrag: enableDrag,
//     transitionAnimationController: transitionAnimationController,
//   );
// }

/// Asserts that the given context has a [SimpleSheetScaffold] ancestor.
///
/// Used by various widgets to make sure that they are only used in an
/// appropriate context.
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasSimpleSheetScaffold(context));
/// ```
///
/// Always place this before any early returns, so that the invariant is checked
/// in all cases. This prevents bugs from hiding until a particular codepath is
/// hit.
///
/// This method can be expensive (it walks the element tree).
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasSimpleSheetScaffold(BuildContext context) {
  assert(
    () {
      if (context.widget is! SimpleSheetScaffold &&
          context.findAncestorWidgetOfExactType<SimpleSheetScaffold>() ==
              null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No SimpleSheetScaffold widget found.'),
          ErrorDescription(
            '${context.widget.runtimeType} widgets require a SimpleSheetScaffold widget ancestor.',
          ),
          ...context.describeMissingAncestor(
            expectedAncestorType: SimpleSheetScaffold,
          ),
          ErrorHint(
            'Typically, the SimpleSheetScaffold widget is introduced by the MaterialApp or '
            'WidgetsApp widget at the top of your application widget tree.',
          ),
        ]);
      }
      return true;
    }(),
    '',
  );
  return true;
}

// =============================================================================

// Used to communicate the height of the Scaffold's bottomNavigationBar and
// persistentFooterButtons to the LayoutBuilder which builds the Scaffold's body.
//
// Scaffold expects a _BodyBoxConstraints to be passed to the _BodyBuilder
// widget's LayoutBuilder, see _ScaffoldLayout.performLayout(). The BoxConstraints
// methods that construct new BoxConstraints objects, like copyWith() have not
// been overridden here because we expect the _BodyBoxConstraintsObject to be
// passed along unmodified to the LayoutBuilder. If that changes in the future
// then _BodyBuilder will assert.
class _BodyBoxConstraints extends BoxConstraints {
  const _BodyBoxConstraints({
    required this.bottomWidgetsHeight,
    super.maxWidth,
    super.maxHeight,
  });

  final double bottomWidgetsHeight;

  // RenderObject.layout() will only short-circuit its call to its performLayout
  // method if the new layout constraints are not == to the current constraints.
  // If the height of the bottom widgets has changed, even though the constraints'
  // min and max values have not, we still want performLayout to happen.
  @override
  bool operator ==(Object other) {
    if (super != other) {
      return false;
    }
    return other is _BodyBoxConstraints &&
        other.bottomWidgetsHeight == bottomWidgetsHeight;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        bottomWidgetsHeight,
      );
}

// Used when Scaffold.extendBody is true to wrap the scaffold's body in a MediaQuery
// whose padding accounts for the height of the bottomNavigationBar and/or the
// persistentFooterButtons.
//
// The bottom widgets' height is passed along via the _BodyBoxConstraints parameter.
// The constraints parameter is constructed in_ScaffoldLayout.performLayout().
class _BodyBuilder extends StatelessWidget {
  const _BodyBuilder({
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bodyConstraints = constraints as _BodyBoxConstraints;
        final metrics = MediaQuery.of(context);

        final bottom = math.max(
          metrics.padding.bottom,
          bodyConstraints.bottomWidgetsHeight,
        );

        // print(bottom);

        return MediaQuery(
          data: metrics.copyWith(
            padding: metrics.padding.copyWith(bottom: bottom),
          ),
          child: body,
        );
      },
    );
  }
}

// =============================================================================

class _ScaffoldLayout extends MultiChildLayoutDelegate {
  _ScaffoldLayout({required this.progress});

  final double progress;

  @override
  void performLayout(Size size) {
    // log('progress => $progress');
    final looseConstraints = BoxConstraints.loose(size);
    final fullWidthConstraints = looseConstraints.tighten(width: size.width);

    final hasBottomSheet = hasChild('SimpleSheet.sheet');

    final bottomWidgetsHeight =
        hasBottomSheet ? size.height * progress.clamp(0.0, 0.45) : 0.0;

    if (hasChild('SimpleSheet.body')) {
      layoutChild(
        'SimpleSheet.body',
        _BodyBoxConstraints(
          maxHeight: size.height - bottomWidgetsHeight,
          maxWidth: fullWidthConstraints.maxWidth,
          bottomWidgetsHeight: bottomWidgetsHeight,
        ),
      );
      positionChild('SimpleSheet.body', Offset.zero);
    }

    if (hasBottomSheet) {
      layoutChild('SimpleSheet.sheet', fullWidthConstraints);
      positionChild(
        'SimpleSheet.sheet',
        Offset(0, size.height - size.height * progress),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

// =============================================================================

class _DismissSheetAction extends DismissAction {
  _DismissSheetAction(this.context);

  final BuildContext context;

  @override
  bool isEnabled(DismissIntent intent) {
    return SimpleSheetScaffold.of(context).isSheetOpen;
  }

  @override
  void invoke(DismissIntent intent) {
    // SimpleSheetScaffold.of(context).closeSheet();
  }
}

// =============================================================================

// ///
// /// The [startingPoint] and [curve] arguments must not be null.
// class _BottomSheetSuspendedCurve extends ParametricCurve<double> {
//   /// Creates a suspended curve.
//   const _BottomSheetSuspendedCurve(
//     this.startingPoint, {
//     this.curve = Curves.easeOutCubic,
//   });

//   /// The progress value at which [curve] should begin.
//   ///
//   /// This defaults to [Curves.easeOutCubic].
//   final double startingPoint;

//   /// The curve to use when [startingPoint] is reached.
//   final Curve curve;

//   @override
//   double transform(double t) {
//     assert(t >= 0.0 && t <= 1.0, '');
//     assert(startingPoint >= 0.0 && startingPoint <= 1.0, '');

//     if (t < startingPoint) {
//       return t;
//     }

//     if (t == 1.0) {
//       return t;
//     }

//     final curveProgress = (t - startingPoint) / (1 - startingPoint);
//     final transformed = curve.transform(curveProgress);
//     return lerpDouble(startingPoint, 1, transformed)!;
//   }

//   @override
//   String toString() {
//     return '${describeIdentity(this)}($startingPoint, $curve)';
//   }
// }

class _StandardBottomSheet extends StatefulWidget {
  const _StandardBottomSheet({
    required this.animationController,
    required this.onClosing,
    required this.onDismissed,
    required this.builder,
    this.enableDrag = true,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.onDispose,
    super.key,
  });

  final AnimationController
      animationController; // we control it, but it must be disposed by whoever created it.
  final bool enableDrag;
  final VoidCallback? onClosing;
  final VoidCallback? onDismissed;
  final VoidCallback? onDispose;
  final WidgetBuilder builder;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;

  @override
  _StandardBottomSheetState createState() => _StandardBottomSheetState();
}

class _StandardBottomSheetState extends State<_StandardBottomSheet> {
  // ParametricCurve<double> animationCurve = _standardBottomSheetCurve;

  @override
  void initState() {
    super.initState();
    assert(
      widget.animationController.status == AnimationStatus.forward ||
          widget.animationController.status == AnimationStatus.completed,
      '',
    );
    widget.animationController.addStatusListener(_handleStatusChange);
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  void didUpdateWidget(_StandardBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.animationController == oldWidget.animationController, '');
  }

  void close() {
    // Fully open
    if (widget.animationController.value > 0.45) {
      widget.animationController.animateTo(0.45);
    } else {
      widget.animationController.reverse();
    }
    widget.onClosing?.call();
  }

  void _handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    // animationCurve = Curves.linear;
  }

  void _handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    // animationCurve = _BottomSheetSuspendedCurve(
    //   widget.animationController.value,
    //   curve: _standardBottomSheetCurve,
    // );
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      widget.onDismissed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Listener(
    //   onPointerDown: _onPointerDown,
    //   onPointerMove: _onPointerMove,
    //   onPointerUp: _onPointerUp,
    //   child: widget.child ?? const SizedBox(),
    // );
    return Semantics(
      container: true,
      // onDismiss: !widget.isPersistent ? close : null,
      onDismiss: close,
      child: DragGesture(
        animationController: widget.animationController,
        onDragStart: _handleDragStart,
        onDragEnd: _handleDragEnd,
        onClosing: widget.onClosing!,
        builder: widget.builder,
      ),
    );
    // return AnimatedBuilder(
    //   animation: widget.animationController,
    //   builder: (BuildContext context, Widget? child) {
    //     return Align(
    //       alignment: AlignmentDirectional.topStart,
    //       heightFactor:
    //           animationCurve.transform(widget.animationController.value),
    //       child: child,
    //     );
    //   },
    //   child: Semantics(
    //     container: true,
    //     // onDismiss: !widget.isPersistent ? close : null,
    //     onDismiss: close,
    //     child: NotificationListener<DraggableScrollableNotification>(
    //       onNotification: extentChanged,
    //       child: BottomSheet(
    //         animationController: widget.animationController,
    //         enableDrag: widget.enableDrag,
    //         onDragStart: _handleDragStart,
    //         onDragEnd: _handleDragEnd,
    //         onClosing: widget.onClosing!,
    //         builder: widget.builder,
    //         backgroundColor: widget.backgroundColor,
    //         elevation: widget.elevation,
    //         shape: widget.shape,
    //         clipBehavior: widget.clipBehavior,
    //         constraints: widget.constraints,
    //       ),
    //     ),
    //   ),
    // );
  }
}
