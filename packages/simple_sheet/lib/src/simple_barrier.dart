// import 'package:flutter/material.dart';

// ///
// class SimpleBarrier extends StatelessWidget {
//   ///
//   const SimpleBarrier({
//     required this.onDismiss,
//     super.key,
//   });

//   ///
//   final VoidCallback onDismiss;

//   @override
//   Widget build(BuildContext context) {
//     return _ModalBarrierGestureDetector(
//       onDismiss: onDismiss,
//       child: const SizedBox.expand(),
//       // child: Semantics(
//       //   onDismiss: onDismiss,
//       //   child: const SizedBox.expand(),
//       // ),
//     );
//   }
// }

// // A GestureDetector used by ModalBarrier. It only has one callback,
// // [onAnyTapDown], which recognizes tap down unconditionally.
// class _ModalBarrierGestureDetector extends StatelessWidget {
//   const _ModalBarrierGestureDetector({
//     required this.child,
//     required this.onDismiss,
//   });

//   /// The widget below this widget in the tree.
//   /// See [RawGestureDetector.child].
//   final Widget child;

//   /// Immediately called when an event that should dismiss the modal barrier
//   /// has happened.
//   final VoidCallback onDismiss;

//   @override
//   Widget build(BuildContext context) {
//     // final gestures = <Type, GestureRecognizerFactory>{
//     //   _AnyTapGestureRecognizer:
//     //       _AnyTapGestureRecognizerFactory(onAnyTapUp: onDismiss),
//     // };

//     return GestureDetector(
//       // gestures: gestures,
//       onTap: onDismiss,
//       behavior: HitTestBehavior.translucent,
//       // semantics: _ModalBarrierSemanticsDelegate(onDismiss: onDismiss),
//       child: child,
//     );
//   }
// }

// // class _AnyTapGestureRecognizerFactory
// //     extends GestureRecognizerFactory<_AnyTapGestureRecognizer> {
// //   const _AnyTapGestureRecognizerFactory();

// //   final VoidCallback? onAnyTapUp;

// //   @override
// //   _AnyTapGestureRecognizer constructor() => _AnyTapGestureRecognizer();

// //   @override
// //   void initializer(_AnyTapGestureRecognizer instance) {
// //     instance.onAnyTapUp = onAnyTapUp;
// //   }
// // }

// // Recognizes tap down by any pointer button.
// //
// // It is similar to [TapGestureRecognizer.onTapDown], but accepts any single
// // button, which means the gesture also takes parts in gesture arenas.
// // class _AnyTapGestureRecognizer extends BaseTapGestureRecognizer {
// //   _AnyTapGestureRecognizer();

// //   VoidCallback? onAnyTapUp;

// //   @protected
// //   @override
// //   bool isPointerAllowed(PointerDownEvent event) {
// //     if (onAnyTapUp == null) {
// //       return false;
// //     }
// //     return super.isPointerAllowed(event);
// //   }

// //   @protected
// //   @override
// //   void handleTapDown({PointerDownEvent? down}) {
// //     // Do nothing.
// //   }

// //   @protected
// //   @override
// //   void handleTapUp({PointerDownEvent? down, PointerUpEvent? up}) {
// //     onAnyTapUp?.call();
// //   }

// //   @protected
// //   @override
// //   void handleTapCancel({
// //     PointerDownEvent? down,
// //     PointerCancelEvent? cancel,
// //     String? reason,
// //   }) {
// //     // Do nothing.
// //   }

// //   @override
// //   String get debugDescription => 'any tap';
// // }

// // class _ModalBarrierSemanticsDelegate extends SemanticsGestureDelegate {
// //   const _ModalBarrierSemanticsDelegate();

// //   final VoidCallback? onDismiss;

// //   @override
// //   void assignSemantics(RenderSemanticsGestureHandler renderObject) {
// //     renderObject.onTap = onDismiss;
// //   }
// // }
