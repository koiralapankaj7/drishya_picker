import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:simple_sheet/src/simple_draggable.dart';

// =============================================================================
///
class SimpleSheet extends StatefulWidget {
  ///
  const SimpleSheet({
    required this.child,
    super.key,
  });

  ///
  final Widget child;

  ///
  static SimpleSheetState of(BuildContext context) {
    final result = context.findAncestorStateOfType<SimpleSheetState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'SimpleSheet.of() called with a context that does not contain a SimpleSheet.',
      ),
      ErrorDescription(
        'No SimpleSheet ancestor could be found starting from the context that was passed to SimpleSheet.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the SimpleSheet widget being sought.',
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
        'context that is "under" the SimpleSheet. For an example of this, please see the '
        'documentation for Scaffold.of() for referance:\n'
        '  https://api.flutter.dev/flutter/material/Scaffold/of.html',
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into several widgets. This '
        'introduces a new context from which you can obtain the SimpleSheet. In this solution, '
        'you would have an outer widget that creates the SimpleSheet populated by instances of '
        'your new inner widgets, and then in these inner widgets you would use SimpleSheet.of().\n'
        'A less elegant but more expedient solution is assign a GlobalKey to the SimpleSheet, '
        'then use the key.currentState property to obtain the SimpleSheetState rather than '
        'using the SimpleSheet.of() function.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  ///
  static SimpleSheetState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SimpleSheetState>();
  }

  @override
  State<SimpleSheet> createState() => SimpleSheetState();
}

///
class SimpleSheetState extends State<SimpleSheet>
    with TickerProviderStateMixin {
  SimpleSheetController<dynamic>? _currentSheet;

  ///
  bool get isSheetOpen => _currentSheet != null;

  void _closeCurrentSheet() {
    if (_currentSheet != null) {
      _currentSheet!.close();
    }
  }

  SimpleSheetController<T> _buildSheet<T>({
    required DraggableWidgetBuilder builder,
    required SDController controller,
    required bool needDisposeController,
  }) {
    final completer = Completer<T>();
    var removedEntry = false;
    const doingDispose = false;

    void removeCurrentBottomSheet() {
      removedEntry = true;
      if (_currentSheet == null) return;
      controller.close();
      completer.complete();
    }

    final entry = LocalHistoryEntry(
      onRemove: removeCurrentBottomSheet,
      impliesAppBarDismissal: false,
    );

    void removeEntryIfNeeded() {
      if (!removedEntry) {
        entry.remove();
        removedEntry = true;
      }
    }

    void listener() {
      if (controller.animation.value <= 0 && _currentSheet != null) {
        log('This is from listener ===>>');
        setState(() {
          _currentSheet = null;
        });
      }
    }

    controller.addListener(listener);

    final bottomSheet = _StandardSheet(
      child: SimpleDraggable(
        builder: builder,
        controller: controller,
        // setting: const SDraggableSetting(),
        // midThreshold: minOffset,
        // onClosing: () {
        //   if (_currentSheet == null) {
        //     return;
        //   }
        //   removeEntryIfNeeded();
        // },
        // onClose: () {
        //   removeEntryIfNeeded();
        //   setState(() {
        //     _currentSheet = null;
        //   });
        // },
        // onDispose: () {
        //   doingDispose = true;
        //
        //   if (disposeController) {
        //     animationController.dispose();
        //   }
        // },
      ),
      onInit: () {
        // TODO : This is only for test may not required
        controller.open();
      },
      onDispose: () {
        removeEntryIfNeeded();
        controller.removeListener(listener);
        if (needDisposeController) {
          controller.dispose();
        }
      },
    );

    ///
    ModalRoute.of(context)!.addLocalHistoryEntry(entry);

    return SimpleSheetController._(
      bottomSheet,
      completer,
      entry.remove,
      controller,
    );
  }

  ///
  SimpleSheetController<T> show<T>({
    required DraggableWidgetBuilder builder,
    SDController? sdController,
    ScrollController? scrollController,
    SimpleDraggableDelegate? delegate,
  }) {
    assert(debugCheckHasSimpleSheet(context), '');
    _closeCurrentSheet();

    final controller = sdController ?? SDController(vsync: this);

    setState(() {
      _currentSheet = _buildSheet(
        builder: builder,
        controller: controller,
        needDisposeController: sdController == null,
      );
    });

    controller.open();

    return _currentSheet! as SimpleSheetController<T>;
  }

  ///
  void close() => _currentSheet?.close();

  @override
  Widget build(BuildContext context) {
    if (_currentSheet == null) {
      return widget.child;
    }

    final animation = _currentSheet!._controller.animation;

    return Material(
      // color: Colors.amber,
      // color: Colors.pink,
      color: Colors.transparent,
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: _DismissSheetAction(context),
        },
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            log('${animation.value}');
            return CustomMultiChildLayout(
              delegate: _ScaffoldLayout(
                progress: animation.value,
              ),
              children: <LayoutId>[
                LayoutId(
                  id: 'SimpleSheet.body',
                  child: _BodyBuilder(
                    body: widget.child,
                  ),
                ),
                LayoutId(
                  id: 'SimpleSheet.sheet',
                  child: _currentSheet!._widget,
                  // child: Container(color: Colors.amber),
                  // child: SimpleDraggable(
                  //   controller: _currentSheet!._controller,
                  //   builder: (context, controller) {
                  //     return Container(
                  //       color: Colors.amber,
                  //     );
                  //   },
                  // ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

///
class SimpleSheetController<T> {
  const SimpleSheetController._(
    this._widget,
    this._completer,
    this.close,
    this._controller,
  );

  final Widget _widget;
  final Completer<T> _completer;
  final SDController _controller;

  /// Completes when the feature controlled by this object is no longer visible.
  Future<T> get closed => _completer.future;

  /// Remove the feature (e.g., bottom sheet, snack bar, or material banner) from the scaffold.
  final VoidCallback close;
}

class _StandardSheet extends StatefulWidget {
  const _StandardSheet({
    required this.child,
    required this.onInit,
    required this.onDispose,
  });

  final Widget child;
  final VoidCallback onDispose;
  final VoidCallback onInit;

  @override
  State<_StandardSheet> createState() => __StandardSheetState();
}

class __StandardSheetState extends State<_StandardSheet> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
// =============================================================================

// ///
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

/// Asserts that the given context has a [SimpleSheet] ancestor.
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
bool debugCheckHasSimpleSheet(BuildContext context) {
  assert(
    () {
      if (context.widget is! SimpleSheet &&
          context.findAncestorWidgetOfExactType<SimpleSheet>() == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No SimpleSheet widget found.'),
          ErrorDescription(
            '${context.widget.runtimeType} widgets require a SimpleSheet widget ancestor.',
          ),
          ...context.describeMissingAncestor(
            expectedAncestorType: SimpleSheet,
          ),
          // ErrorHint(
          //   'Typically, the SimpleSheet widget is introduced by the MaterialApp or '
          //   'WidgetsApp widget at the top of your application widget tree.',
          // ),
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
    return SimpleSheet.of(context).isSheetOpen;
  }

  @override
  void invoke(DismissIntent intent) {
    // SimpleSheetScaffold.of(context).closeSheet();
  }
}

// =============================================================================
