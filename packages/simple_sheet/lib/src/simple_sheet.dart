// import 'dart:async';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:simple_sheet/src/simple_draggable.dart';

// // =============================================================================
// ///
// class SimpleSheet extends StatefulWidget {
//   ///
//   const SimpleSheet({
//     required this.body,
//     this.bottomSheet,
//     this.minOffset = 0.45,
//     super.key,
//   });

//   ///
//   final Widget body;

//   ///
//   final DragWidgetBuilder? bottomSheet;

//   ///
//   final double minOffset;

//   /// Finds the [ScaffoldState] from the closest instance of this class that
//   /// encloses the given context.
//   ///
//   /// If no instance of this class encloses the given context, will cause an
//   /// assert in debug mode, and throw an exception in release mode.
//   ///
//   /// This method can be expensive (it walks the element tree).
//   ///
//   /// {@tool dartpad}
//   /// Typical usage of the [Scaffold.of] function is to call it from within the
//   /// `build` method of a child of a [Scaffold].
//   ///
//   /// ** See code in examples/api/lib/material/scaffold/scaffold.of.0.dart **
//   /// {@end-tool}
//   ///
//   /// {@tool dartpad}
//   /// When the [Scaffold] is actually created in the same `build` function, the
//   /// `context` argument to the `build` function can't be used to find the
//   /// [Scaffold] (since it's "above" the widget being returned in the widget
//   /// tree). In such cases, the following technique with a [Builder] can be used
//   /// to provide a new scope with a [BuildContext] that is "under" the
//   /// [Scaffold]:
//   ///
//   /// ** See code in examples/api/lib/material/scaffold/scaffold.of.1.dart **
//   /// {@end-tool}
//   ///
//   /// A more efficient solution is to split your build function into several
//   /// widgets. This introduces a new context from which you can obtain the
//   /// [Scaffold]. In this solution, you would have an outer widget that creates
//   /// the [Scaffold] populated by instances of your new inner widgets, and then
//   /// in these inner widgets you would use [Scaffold.of].
//   ///
//   /// A less elegant but more expedient solution is assign a [GlobalKey] to the
//   /// [Scaffold], then use the `key.currentState` property to obtain the
//   /// [ScaffoldState] rather than using the [Scaffold.of] function.
//   ///
//   /// If there is no [Scaffold] in scope, then this will throw an exception.
//   /// To return null if there is no [Scaffold], use [maybeOf] instead.
//   static SimpleSheetState of(BuildContext context) {
//     final result = context.findAncestorStateOfType<SimpleSheetState>();
//     if (result != null) {
//       return result;
//     }
//     throw FlutterError.fromParts(<DiagnosticsNode>[
//       ErrorSummary(
//         'SimpleSheetScaffoldState.of() called with a context that does not contain a SimpleSheetScaffoldState.',
//       ),
//       ErrorDescription(
//         'No Scaffold ancestor could be found starting from the context that was passed to Scaffold.of(). '
//         'This usually happens when the context provided is from the same StatefulWidget as that '
//         'whose build function actually creates the Scaffold widget being sought.',
//       ),
//       ErrorHint(
//         'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
//         'context that is "under" the Scaffold. For an example of this, please see the '
//         'documentation for Scaffold.of():\n'
//         '  https://api.flutter.dev/flutter/material/Scaffold/of.html',
//       ),
//       ErrorHint(
//         'A more efficient solution is to split your build function into several widgets. This '
//         'introduces a new context from which you can obtain the Scaffold. In this solution, '
//         'you would have an outer widget that creates the Scaffold populated by instances of '
//         'your new inner widgets, and then in these inner widgets you would use Scaffold.of().\n'
//         'A less elegant but more expedient solution is assign a GlobalKey to the Scaffold, '
//         'then use the key.currentState property to obtain the ScaffoldState rather than '
//         'using the Scaffold.of() function.',
//       ),
//       context.describeElement('The context used was'),
//     ]);
//   }

//   /// Finds the [ScaffoldState] from the closest instance of this class that
//   /// encloses the given context.
//   ///
//   /// If no instance of this class encloses the given context, will return null.
//   /// To throw an exception instead, use [of] instead of this function.
//   ///
//   /// This method can be expensive (it walks the element tree).
//   ///
//   /// See also:
//   ///
//   ///  * [of], a similar function to this one that throws if no instance
//   ///    encloses the given context. Also includes some sample code in its
//   ///    documentation.
//   static SimpleSheetState? maybeOf(BuildContext context) {
//     return context.findAncestorStateOfType<SimpleSheetState>();
//   }

//   @override
//   State<SimpleSheet> createState() => SimpleSheetState();
// }

// ///
// class SimpleSheetState extends State<SimpleSheet>
//     with TickerProviderStateMixin {
//   SimpleDraggable? _currentSheet;

//   @override
//   void initState() {
//     super.initState();
//     _setupSheet();
//   }

//   void _setupSheet() {
//     if (widget.bottomSheet != null) {
//       assert(_currentSheet == null, '');
//       _currentSheet = _buildBottomSheet<void>(
//         widget.bottomSheet!,
//         animationController: BottomSheet.createAnimationController(this),
//         minOffset: widget.minOffset,
//         disposeController: true,
//       );
//     }
//   }

//   ///
//   bool get isSheetOpen => _currentSheet != null;

//   SimpleDraggable _buildBottomSheet<T>(
//     DragWidgetBuilder builder, {
//     required AnimationController animationController,
//     required double minOffset,
//     required bool disposeController,
//   }) {
//     assert(
//       () {
//         if (widget.bottomSheet != null && _currentSheet != null) {
//           throw FlutterError(
//             'SimpleSheet.bottomSheet cannot be specified while a simple sheet '
//             'displayed with showSimpleSheet() is still visible.\n'
//             'Rebuild the SimpleSheet with a null simpleSheet before calling showSimpleSheet().',
//           );
//         }
//         return true;
//       }(),
//       '',
//     );

//     final completer = Completer<T>();

//     var removedEntry = false;
//     var doingDispose = false;

//     void removeCurrentBottomSheet() {
//       removedEntry = true;
//       if (_currentSheet == null) {
//         return;
//       }
//       // assert(bottomSheetKey.currentState != null, '');
//       // bottomSheetKey.currentState!.close(); // TODO
//       completer.complete();
//     }

//     final entry = LocalHistoryEntry(
//       onRemove: removeCurrentBottomSheet,
//       impliesAppBarDismissal: false,
//     );

//     void removeEntryIfNeeded() {
//       if (!removedEntry) {
//         entry.remove();
//         removedEntry = true;
//       }
//     }

//     final bottomSheet = SimpleDraggable(
//       // key: bottomSheetKey,
//       // animationController: animationController,
//       midThreshold: minOffset,
//       onClosing: () {
//         if (_currentSheet == null) {
//           return;
//         }
//         removeEntryIfNeeded();
//       },
//       onClose: () {
//         removeEntryIfNeeded();
//         setState(() {
//           _currentSheet = null;
//         });
//       },
//       onDispose: () {
//         doingDispose = true;
//         removeEntryIfNeeded();
//         if (disposeController) {
//           animationController.dispose();
//         }
//       },
//       builder: builder,
//     );

//     ///
//     ModalRoute.of(context)!.addLocalHistoryEntry(entry);

//     return bottomSheet;

//     // return PersistentBottomSheetController<T>._(
//     //   bottomSheet,
//     //   completer,
//     //   entry != null ? entry.remove : removeCurrentBottomSheet,
//     //   (VoidCallback fn) {
//     //     bottomSheetKey.currentState?.setState(fn);
//     //   },
//     //   !isPersistent,
//     // );
//   }

//   void _closeCurrentSheet() {
//     if (_currentSheet != null) {
//       // if (!_currentSheet!._isLocalHistoryEntry) {
//       //   _currentSheet!.close();
//       // }
//       assert(
//         () {
//           // _currentSheet?._completer.future.whenComplete(() {
//           //   assert(_currentBottomSheet == null);
//           // });
//           return true;
//         }(),
//         '',
//       );
//     }
//   }

//   ///
//   void show<T>(
//     DragWidgetBuilder builder, {
//     AnimationController? animationController,
//     double minOffset = 0.45,
//   }) {
//     assert(
//       () {
//         if (widget.bottomSheet != null && _currentSheet != null) {
//           throw FlutterError(
//             'SimpleSheet.bottomSheet cannot be specified while a simple sheet '
//             'displayed with showSimpleSheet() is still visible.\n'
//             'Rebuild the SimpleSheet with a null simpleSheet before calling showSimpleSheet().',
//           );
//         }
//         return true;
//       }(),
//       '',
//     );
//     assert(debugCheckHasSimpleSheet(context), '');

//     // if (_currentSheet != null) {
//     //   Navigator.of(context).pop();
//     //   return;
//     // }
//     _closeCurrentSheet();

//     final controller = (animationController ??
//         BottomSheet.createAnimationController(this))
//       ..snapToPosition(minOffset);

//     setState(() {
//       _currentSheet = _buildBottomSheet<T>(
//         builder,
//         animationController: controller,
//         minOffset: minOffset,
//         disposeController: animationController == null,
//       );
//     });
//     // return _currentBottomSheet! as PersistentBottomSheetController<T>;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentSheet == null) {
//       return widget.body;
//     }

//     final controller = bottomSheetKey.currentState?.controller;

//     if (controller == null) return const SizedBox();

//     return Material(
//       // color: Colors.amber,
//       color: Colors.pink,
//       child: AnimatedBuilder(
//         animation: controller,
//         builder: (context, child) {
//           return Actions(
//             actions: <Type, Action<Intent>>{
//               DismissIntent: _DismissSheetAction(context),
//             },
//             child: CustomMultiChildLayout(
//               delegate: _ScaffoldLayout(
//                 progress: controller.value,
//               ),
//               children: <LayoutId>[
//                 LayoutId(
//                   id: 'SimpleSheet.body',
//                   child: _BodyBuilder(
//                     body: widget.body,
//                   ),
//                 ),
//                 if (_currentSheet != null)
//                   LayoutId(
//                     id: 'SimpleSheet.sheet',
//                     child: _currentSheet!,
//                     // child: SSController(
//                     //   key: _sheetKey,
//                     //   alignment: DrawerAlignment.start,
//                     //   drawerCallback: (isOpened) {
//                     //     if (isOpened) {}
//                     //   },
//                     //   child: _currentBottomSheet!,
//                     // ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // =============================================================================

// ///
// // PersistentBottomSheetController<T> showSimpleSheet<T>({
// //   required BuildContext context,
// //   required WidgetBuilder builder,
// //   Color? backgroundColor,
// //   double? elevation,
// //   ShapeBorder? shape,
// //   Clip? clipBehavior,
// //   BoxConstraints? constraints,
// //   bool? enableDrag,
// //   AnimationController? transitionAnimationController,
// // }) {
// //   assert(debugCheckHasSimpleSheetScaffold(context), '');

// //   return Scaffold.of(context).showBottomSheet<T>(
// //     builder,
// //     backgroundColor: backgroundColor,
// //     elevation: elevation,
// //     shape: shape,
// //     clipBehavior: clipBehavior,
// //     constraints: constraints,
// //     enableDrag: enableDrag,
// //     transitionAnimationController: transitionAnimationController,
// //   );
// // }

// /// Asserts that the given context has a [SimpleSheet] ancestor.
// ///
// /// Used by various widgets to make sure that they are only used in an
// /// appropriate context.
// ///
// /// To invoke this function, use the following pattern, typically in the
// /// relevant Widget's build method:
// ///
// /// ```dart
// /// assert(debugCheckHasSimpleSheetScaffold(context));
// /// ```
// ///
// /// Always place this before any early returns, so that the invariant is checked
// /// in all cases. This prevents bugs from hiding until a particular codepath is
// /// hit.
// ///
// /// This method can be expensive (it walks the element tree).
// ///
// /// Does nothing if asserts are disabled. Always returns true.
// bool debugCheckHasSimpleSheet(BuildContext context) {
//   assert(
//     () {
//       if (context.widget is! SimpleSheet &&
//           context.findAncestorWidgetOfExactType<SimpleSheet>() == null) {
//         throw FlutterError.fromParts(<DiagnosticsNode>[
//           ErrorSummary('No SimpleSheet widget found.'),
//           ErrorDescription(
//             '${context.widget.runtimeType} widgets require a SimpleSheet widget ancestor.',
//           ),
//           ...context.describeMissingAncestor(
//             expectedAncestorType: SimpleSheet,
//           ),
//           // ErrorHint(
//           //   'Typically, the SimpleSheet widget is introduced by the MaterialApp or '
//           //   'WidgetsApp widget at the top of your application widget tree.',
//           // ),
//         ]);
//       }
//       return true;
//     }(),
//     '',
//   );
//   return true;
// }

// // =============================================================================

// // Used to communicate the height of the Scaffold's bottomNavigationBar and
// // persistentFooterButtons to the LayoutBuilder which builds the Scaffold's body.
// //
// // Scaffold expects a _BodyBoxConstraints to be passed to the _BodyBuilder
// // widget's LayoutBuilder, see _ScaffoldLayout.performLayout(). The BoxConstraints
// // methods that construct new BoxConstraints objects, like copyWith() have not
// // been overridden here because we expect the _BodyBoxConstraintsObject to be
// // passed along unmodified to the LayoutBuilder. If that changes in the future
// // then _BodyBuilder will assert.
// class _BodyBoxConstraints extends BoxConstraints {
//   const _BodyBoxConstraints({
//     required this.bottomWidgetsHeight,
//     super.maxWidth,
//     super.maxHeight,
//   });

//   final double bottomWidgetsHeight;

//   // RenderObject.layout() will only short-circuit its call to its performLayout
//   // method if the new layout constraints are not == to the current constraints.
//   // If the height of the bottom widgets has changed, even though the constraints'
//   // min and max values have not, we still want performLayout to happen.
//   @override
//   bool operator ==(Object other) {
//     if (super != other) {
//       return false;
//     }
//     return other is _BodyBoxConstraints &&
//         other.bottomWidgetsHeight == bottomWidgetsHeight;
//   }

//   @override
//   int get hashCode => Object.hash(
//         super.hashCode,
//         bottomWidgetsHeight,
//       );
// }

// // Used when Scaffold.extendBody is true to wrap the scaffold's body in a MediaQuery
// // whose padding accounts for the height of the bottomNavigationBar and/or the
// // persistentFooterButtons.
// //
// // The bottom widgets' height is passed along via the _BodyBoxConstraints parameter.
// // The constraints parameter is constructed in_ScaffoldLayout.performLayout().
// class _BodyBuilder extends StatelessWidget {
//   const _BodyBuilder({
//     required this.body,
//   });

//   final Widget body;

//   @override
//   Widget build(BuildContext context) {
//     DraggableScrollableSheet(builder: builder)
//     return LayoutBuilder(
//       builder: (BuildContext context, BoxConstraints constraints) {
//         final bodyConstraints = constraints as _BodyBoxConstraints;
//         final metrics = MediaQuery.of(context);

//         final bottom = math.max(
//           metrics.padding.bottom,
//           bodyConstraints.bottomWidgetsHeight,
//         );

//         // print(bottom);

//         return MediaQuery(
//           data: metrics.copyWith(
//             padding: metrics.padding.copyWith(bottom: bottom),
//           ),
//           child: body,
//         );
//       },
//     );
//   }
// }

// // =============================================================================

// class _ScaffoldLayout extends MultiChildLayoutDelegate {
//   _ScaffoldLayout({required this.progress});

//   final double progress;

//   @override
//   void performLayout(Size size) {
//     // log('progress => $progress');
//     final looseConstraints = BoxConstraints.loose(size);
//     final fullWidthConstraints = looseConstraints.tighten(width: size.width);

//     final hasBottomSheet = hasChild('SimpleSheet.sheet');

//     final bottomWidgetsHeight =
//         hasBottomSheet ? size.height * progress.clamp(0.0, 0.45) : 0.0;

//     if (hasChild('SimpleSheet.body')) {
//       layoutChild(
//         'SimpleSheet.body',
//         _BodyBoxConstraints(
//           maxHeight: size.height - bottomWidgetsHeight,
//           maxWidth: fullWidthConstraints.maxWidth,
//           bottomWidgetsHeight: bottomWidgetsHeight,
//         ),
//       );
//       positionChild('SimpleSheet.body', Offset.zero);
//     }

//     // log('$progress');

//     if (hasBottomSheet) {
//       layoutChild('SimpleSheet.sheet', fullWidthConstraints);
//       positionChild(
//         'SimpleSheet.sheet',
//         Offset(0, size.height - size.height * progress),
//       );
//     }
//   }

//   @override
//   bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
//     return true;
//   }
// }

// // =============================================================================

// class _DismissSheetAction extends DismissAction {
//   _DismissSheetAction(this.context);

//   final BuildContext context;

//   @override
//   bool isEnabled(DismissIntent intent) {
//     return SimpleSheet.of(context).isSheetOpen;
//   }

//   @override
//   void invoke(DismissIntent intent) {
//     // SimpleSheetScaffold.of(context).closeSheet();
//   }
// }

// // =============================================================================

// // ///
// // /// The [startingPoint] and [curve] arguments must not be null.
// // class _BottomSheetSuspendedCurve extends ParametricCurve<double> {
// //   /// Creates a suspended curve.
// //   const _BottomSheetSuspendedCurve(
// //     this.startingPoint, {
// //     this.curve = Curves.easeOutCubic,
// //   });

// //   /// The progress value at which [curve] should begin.
// //   ///
// //   /// This defaults to [Curves.easeOutCubic].
// //   final double startingPoint;

// //   /// The curve to use when [startingPoint] is reached.
// //   final Curve curve;

// //   @override
// //   double transform(double t) {
// //     assert(t >= 0.0 && t <= 1.0, '');
// //     assert(startingPoint >= 0.0 && startingPoint <= 1.0, '');

// //     if (t < startingPoint) {
// //       return t;
// //     }

// //     if (t == 1.0) {
// //       return t;
// //     }

// //     final curveProgress = (t - startingPoint) / (1 - startingPoint);
// //     final transformed = curve.transform(curveProgress);
// //     return lerpDouble(startingPoint, 1, transformed)!;
// //   }

// //   @override
// //   String toString() {
// //     return '${describeIdentity(this)}($startingPoint, $curve)';
// //   }
// // }

// // class _StandardBottomSheet extends StatefulWidget {
// //   const _StandardBottomSheet({
// //     required this.animationController,
// //     required this.onClosing,
// //     required this.onDismissed,
// //     required this.builder,
// //     this.enableDrag = true,
// //     this.backgroundColor,
// //     this.elevation,
// //     this.shape,
// //     this.clipBehavior,
// //     this.constraints,
// //     this.onDispose,
// //     super.key,
// //   });

// //   final AnimationController
// //       animationController; // we control it, but it must be disposed by whoever created it.
// //   final bool enableDrag;
// //   final VoidCallback? onClosing;
// //   final VoidCallback? onDismissed;
// //   final VoidCallback? onDispose;
// //   final DragWidgetBuilder builder;
// //   final Color? backgroundColor;
// //   final double? elevation;
// //   final ShapeBorder? shape;
// //   final Clip? clipBehavior;
// //   final BoxConstraints? constraints;

// //   @override
// //   _StandardBottomSheetState createState() => _StandardBottomSheetState();
// // }

// // class _StandardBottomSheetState extends State<_StandardBottomSheet> {
// //   // ParametricCurve<double> animationCurve = _standardBottomSheetCurve;

// //   @override
// //   void initState() {
// //     super.initState();
// //     assert(
// //       widget.animationController.status == AnimationStatus.forward ||
// //           widget.animationController.status == AnimationStatus.completed,
// //       '',
// //     );
// //     widget.animationController.addStatusListener(_handleStatusChange);
// //   }

// //   @override
// //   void dispose() {
// //     widget.onDispose?.call();
// //     super.dispose();
// //   }

// //   @override
// //   void didUpdateWidget(_StandardBottomSheet oldWidget) {
// //     super.didUpdateWidget(oldWidget);
// //     assert(widget.animationController == oldWidget.animationController, '');
// //   }

// //   // void close() {
// //   //   // Fully open
// //   //   if (widget.animationController.value > 0.45) {
// //   //     widget.animationController.animateTo(0.45);
// //   //   } else {
// //   //     widget.animationController.reverse();
// //   //   }
// //   //   widget.onClosing?.call();
// //   // }

// //   // void _handleDragStart(DragStartDetails details) {
// //   // Allow the bottom sheet to track the user's finger accurately.
// //   // animationCurve = Curves.linear;
// //   // }

// //   // void _handleDragEnd(DragEndDetails details, {bool? isClosing}) {
// //   // Allow the bottom sheet to animate smoothly from its current position.
// //   // animationCurve = _BottomSheetSuspendedCurve(
// //   //   widget.animationController.value,
// //   //   curve: _standardBottomSheetCurve,
// //   // );
// //   // }

// //   void _handleStatusChange(AnimationStatus status) {
// //     if (status == AnimationStatus.dismissed) {
// //       widget.onDismissed?.call();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return DragGesture(
// //       animationController: widget.animationController,
// //       onClosing: widget.onClosing!,
// //       builder: widget.builder,
// //     );
// //     // return AnimatedBuilder(
// //     //   animation: widget.animationController,
// //     //   builder: (BuildContext context, Widget? child) {
// //     //     return Align(
// //     //       alignment: AlignmentDirectional.topStart,
// //     //       heightFactor:
// //     //           animationCurve.transform(widget.animationController.value),
// //     //       child: child,
// //     //     );
// //     //   },
// //     //   child: Semantics(
// //     //     container: true,
// //     //     // onDismiss: !widget.isPersistent ? close : null,
// //     //     onDismiss: close,
// //     //     child: NotificationListener<DraggableScrollableNotification>(
// //     //       onNotification: extentChanged,
// //     //       child: BottomSheet(
// //     //         animationController: widget.animationController,
// //     //         enableDrag: widget.enableDrag,
// //     //         onDragStart: _handleDragStart,
// //     //         onDragEnd: _handleDragEnd,
// //     //         onClosing: widget.onClosing!,
// //     //         builder: widget.builder,
// //     //         backgroundColor: widget.backgroundColor,
// //     //         elevation: widget.elevation,
// //     //         shape: widget.shape,
// //     //         clipBehavior: widget.clipBehavior,
// //     //         constraints: widget.constraints,
// //     //       ),
// //     //     ),
// //     //   ),
// //     // );
// //   }
// // }
