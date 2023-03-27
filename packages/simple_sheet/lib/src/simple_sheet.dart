// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:simple_sheet/src/simple_draggable.dart';

class _DraggableScope extends InheritedWidget {
  const _DraggableScope({
    required this.controller,
    required super.child,
  });

  final SDController controller;

  @override
  bool updateShouldNotify(_DraggableScope old) {
    return controller != old.controller;
  }
}

// =============================================================================
///
class SimpleDraggableScope extends StatefulWidget {
  ///
  const SimpleDraggableScope({
    required this.child,
    // this.controller,
    super.key,
  });

  ///
  final Widget child;

  // ///
  // final SDController? controller;

  ///
  static SimpleDraggableScopeState of(BuildContext context) {
    final result = context.findAncestorStateOfType<SimpleDraggableScopeState>();
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
  static SimpleDraggableScopeState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SimpleDraggableScopeState>();
  }

  @override
  State<SimpleDraggableScope> createState() => SimpleDraggableScopeState();
}

///
class SimpleDraggableScopeState extends State<SimpleDraggableScope>
    with TickerProviderStateMixin {
  bool _keepAlive = false;
  SimpleSheetController<dynamic>? _currentSheet;

  // OverlayEntry? _entry;

  ///
  bool get isSheetOpen => _currentSheet != null;

  void _closeCurrentSheet() {
    if (_currentSheet != null) {
      _currentSheet!.close();
    }
  }

  // void _buildOverlay({
  //   required DraggableWidgetBuilder builder,
  //   required SDController controller,
  //   required bool needDisposeController,
  // }) {
  //   _entry = OverlayEntry(
  //     builder: (context) {
  //       return _StandardSheet(
  //         child: SimpleDraggable(
  //           builder: builder,
  //           controller: controller,
  //         ),
  //         onInit: () {},
  //         onDispose: () {
  //           // removeEntryIfNeeded();
  //           // controller.removeListener(listener);
  //           // if (needDisposeController) {
  //           //   controller.dispose();
  //           // }
  //         },
  //       );
  //     },
  //   );
  //   Overlay.of(context).insert(_entry!);
  // }

  // SimpleSheetController<T> _buildSheet<T>({
  //   required DraggableWidgetBuilder builder,
  //   required SDController controller,
  //   required bool needDisposeController,
  // }) {
  //   final completer = Completer<T>();
  //   var removedEntry = false;
  //   const doingDispose = false;

  //   void removeCurrentBottomSheet() {
  //     removedEntry = true;
  //     if (_currentSheet == null) return;
  //     controller.close();
  //     completer.complete('This is from completer' as T);
  //   }

  //   final entry = LocalHistoryEntry(
  //     onRemove: removeCurrentBottomSheet,
  //     impliesAppBarDismissal: false,
  //   );

  //   // Navigator.of(context).push(LocalHistoryRoute)

  //   void removeEntryIfNeeded() {
  //     if (!removedEntry) {
  //       entry.remove();
  //       removedEntry = true;
  //     }
  //   }

  //   void listener() {
  //     if (controller.animation.value <= 0 && _currentSheet != null) {
  //       log('This is from listener ===>>');
  //       setState(() {
  //         _currentSheet = null;
  //       });
  //     }
  //   }

  //   controller.addListener(listener);

  //   final bottomSheet = _StandardSheet(
  //     child: SimpleDraggable(
  //       builder: builder,
  //       controller: controller,
  //       // setting: const SDraggableSetting(),
  //       // midThreshold: minOffset,
  //       // onClosing: () {
  //       //   if (_currentSheet == null) {
  //       //     return;
  //       //   }
  //       //   removeEntryIfNeeded();
  //       // },
  //       // onClose: () {
  //       //   removeEntryIfNeeded();
  //       //   setState(() {
  //       //     _currentSheet = null;
  //       //   });
  //       // },
  //       // onDispose: () {
  //       //   doingDispose = true;
  //       //
  //       //   if (disposeController) {
  //       //     animationController.dispose();
  //       //   }
  //       // },
  //     ),
  //     onInit: () {
  //       // TODO : This is only for test may not required
  //       // controller.open();
  //     },
  //     onDispose: () {
  //       removeEntryIfNeeded();
  //       controller.removeListener(listener);
  //       if (needDisposeController) {
  //         controller.dispose();
  //       }
  //     },
  //   );

  //   ///
  //   ModalRoute.of(context)!.addLocalHistoryEntry(entry);

  //   return SimpleSheetController._(
  //     bottomSheet,
  //     completer,
  //     entry.remove,
  //     controller,
  //   );
  // }

  ///
  Future<T?> show<T>({
    required DraggableWidgetBuilder builder,
    SDController? sdController,
    ScrollController? scrollController,
    SimpleDraggableDelegate? delegate,
    bool keepAlive = false,
  }) {
    assert(debugCheckHasSimpleSheet(context), '');
    _closeCurrentSheet();
    _keepAlive = true;
    var removedEntry = false;
    const doingDispose = false;

    final controller = sdController ?? SDController(vsync: this);
    final completer = Completer<T?>();
    // Future.delayed(Duration.zero, controller.open);
    controller.open();

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
      ),
      onInit: () {},
      onDispose: () {
        removeEntryIfNeeded();
        controller.removeListener(listener);
        if (sdController == null) {
          controller.dispose();
        }
      },
    );

    setState(() {
      _currentSheet = SimpleSheetController._(
        bottomSheet,
        entry.remove,
        controller,
      );
    });

    ///
    ModalRoute.of(context)!.addLocalHistoryEntry(entry);

    return completer.future;
  }

  ///
  void close() => _currentSheet?.close();

  @override
  Widget build(BuildContext context) {
    if (_currentSheet == null) {
      return widget.child;
    }

    final controller = _currentSheet!._controller;
    final animation = controller.animation;

    return _DraggableScope(
      controller: controller,
      child: Material(
        color: Colors.red,
        // color: Colors.pink,
        // color: Colors.transparent,
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: _DismissSheetAction(context),
          },
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    heightFactor: (1 - animation.value)
                        .clamp(1 - controller.snapPoint.offset, 1),
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
                child: widget.child,
              ),

              // Bottom sheet
              _currentSheet!._widget,
            ],
          ),
        ),
      ),
    );
  }
}

///
class SimpleSheetController<T> {
  const SimpleSheetController._(
    this._widget,
    this.close,
    this._controller,
  );

  final Widget _widget;
  final SDController _controller;

  ///
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
  State<_StandardSheet> createState() => _StandardSheetState();
}

class _StandardSheetState extends State<_StandardSheet> {
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

///
bool debugCheckHasSimpleSheet(BuildContext context) {
  assert(
    () {
      if (context.widget is! SimpleDraggableScope &&
          context.findAncestorWidgetOfExactType<SimpleDraggableScope>() ==
              null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No SimpleSheet widget found.'),
          ErrorDescription(
            '${context.widget.runtimeType} widgets require a SimpleSheet widget ancestor.',
          ),
          ...context.describeMissingAncestor(
            expectedAncestorType: SimpleDraggableScope,
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

class _DismissSheetAction extends DismissAction {
  _DismissSheetAction(this.context);

  final BuildContext context;

  @override
  bool isEnabled(DismissIntent intent) {
    return SimpleDraggableScope.of(context).isSheetOpen;
  }

  @override
  void invoke(DismissIntent intent) {
    // SimpleSheetScaffold.of(context).closeSheet();
  }
}

// =========================================================================
