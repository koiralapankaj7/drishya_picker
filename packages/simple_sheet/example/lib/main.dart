import 'package:flutter/material.dart';
import 'package:simple_sheet/simple_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple Sheet Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SimpleSheetScaffold(
      child: Scaffold(
        body: Builder(builder: (context) {
          // return DraggableScrollableSheet(
          //   snap: true,
          //   minChildSize: 0.45,
          //   snapAnimationDuration: const Duration(milliseconds: 100),
          //   builder: (context, controller) {
          //     return ListView.builder(
          //       controller: controller,
          //       itemBuilder: (context, index) {
          //         return Container(
          //           color: Colors.amber,
          //           margin: const EdgeInsets.all(2),
          //           child: Text('$index'),
          //         );
          //       },
          //     );
          //   },
          // );
          return Container(
            color: Colors.cyan,
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                SimpleSheetScaffold.of(context).showBottomSheet((context) {
                  return Container(color: Colors.amber);
                  return Container(
                    color: Colors.black12,
                    alignment: Alignment
                        .topCenter, // TODO remove alignment and see the size issue
                    // child: TextButton(
                    //   onPressed: Navigator.of(context).pop,
                    //   child: const Text('Close'),
                    // ),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.amber,
                          margin: const EdgeInsets.all(2),
                          child: Text('$index'),
                        );
                      },
                    ),
                  );
                });
                // Scaffold.of(context).showBottomSheet(
                //   (context) {
                //     return Container(color: Colors.amber);
                //     // return ListView.builder(
                //     //   itemBuilder: (context, index) => SizedBox(
                //     //     height: 100,
                //     //     child: Text('$index'),
                //     //   ),
                //     // );
                //   },
                //   enableDrag: true,
                // );
              },
              child: const Text('Open'),
            ),
          );
        }),
      ),
      // child: Scaffold(
      //   key: _key,
      //   appBar: AppBar(title: Text(widget.title)),
      //   body: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         const SizedBox(height: 8),

      //         // Textfield
      //         Container(
      //           padding: const EdgeInsets.all(8),
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             boxShadow: [
      //               BoxShadow(
      //                 color: Colors.grey.shade200,
      //                 spreadRadius: 2,
      //                 blurRadius: 10,
      //               ),
      //             ],
      //           ),
      //           child: Row(
      //             children: [
      //               // Textfield
      //               Expanded(child: _TextFieldView(onChanged: (value) {})),

      //               // Gallery field
      //               IconButton(
      //                 onPressed: () {
      //                   Widget builder(BuildContext context) {
      //                     return Scaffold(
      //                       backgroundColor: Colors.transparent,
      //                       body: Container(
      //                         margin: const EdgeInsets.all(64),
      //                         decoration:
      //                             const BoxDecoration(color: Colors.amber),
      //                         child: Center(
      //                           child: IconButton(
      //                             onPressed: Navigator.of(context).pop,
      //                             icon: const Icon(Icons.close),
      //                           ),
      //                         ),
      //                       ),
      //                     );
      //                   }

      //                   // showDialog(
      //                   //   context: context,
      //                   //   builder: (context) => const Text(''),
      //                   // );

      //                   // Navigator.of(context)
      //                   //     .push(CupertinoPageRoute(builder: builder));

      //                   // Navigator.of(context)
      //                   //     .push(CupertinoPageRoute(builder: builder));

      //                   // Navigator.of(context).push(
      //                   //   CustomRoute(
      //                   //     page: Container(
      //                   //       decoration: BoxDecoration(
      //                   //         border: Border.all(),
      //                   //         color: Colors.amber,
      //                   //       ),
      //                   //       child: Center(
      //                   //         child: TextButton(
      //                   //           onPressed: () {
      //                   //             print('lllll');
      //                   //           },
      //                   //           child: const Text('Tap Me'),
      //                   //         ),
      //                   //       ),
      //                   //     ),
      //                   //     key: _key,
      //                   //   ),
      //                   // );

      //                   // Navigator.of(context).push(
      //                   //   MyRoute(
      //                   //     GestureDetector(
      //                   //       onTap: Navigator.of(context).pop,
      //                   //       child: const SizedBox(
      //                   //         height: 400,
      //                   //         width: 400,
      //                   //         child: ColoredBox(color: Colors.red),
      //                   //       ),
      //                   //     ),
      //                   //   ),
      //                   // );

      //                   //
      //                 },
      //                 icon: const Icon(Icons.open_in_browser),
      //               ),

      //               //
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

///
class _TextFieldView extends StatelessWidget {
  ///
  const _TextFieldView({
    required this.onChanged,
  });

  ///
  final ValueSetter<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Set maximum limit..',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onSubmitted: (text) {
        final max = int.tryParse(text);
        if (max != null) {
          onChanged(max);
        }
      },
    );
  }
}

class MyRoute extends ModalRoute<void> {
  MyRoute(this.child);

  final Widget child;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Stack(
      children: [
        child,
      ],
    );
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // secondaryAnimation
    //     .drive(Tween(begin: const Offset(-0.4, 0.0), end: Offset.zero));
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(0.5, 1), end: const Offset(0.5, 0.0)),
      ),
      child: child,
    );
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final entries = super.createOverlayEntries();
    return [entries.last];
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}

class CustomRoute extends PageRouteBuilder {
  final Widget page;
  final double? offset;
  final GlobalKey key;

  CustomRoute({required this.page, required this.key, this.offset})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            double screenHeight = MediaQuery.of(context).size.height;
            double sheetHeight = offset ?? (screenHeight * 0.45);

            return SlideTransition(
              position: secondaryAnimation.drive(Tween<Offset>(
                  begin: Offset.zero, end: const Offset(0.0, -0.5))),
              child: Stack(
                children: [
                  // SlideTransition(
                  //   position: Tween<Offset>(
                  //     begin: const Offset(0, 0),
                  //     end: const Offset(0, -0.45),
                  //   ).animate(
                  //     CurvedAnimation(
                  //       parent: animation,
                  //       curve: Curves.easeInOut,
                  //     ),
                  //   ),
                  //   // child: key.currentContext?.widget,
                  //   child: child,
                  // ),
                  StatefulBuilder(builder: (context, setState) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: sheetHeight,
                      child: GestureDetector(
                        onVerticalDragUpdate: (DragUpdateDetails details) {
                          double scrollPosition = details.localPosition.dy;
                          double scrollPercentage =
                              (scrollPosition / screenHeight).clamp(0, 1);

                          if (scrollPercentage > 0.5) {
                            Navigator.pop(context);
                          } else {
                            sheetHeight =
                                (screenHeight * (1 - scrollPercentage));
                            // Navigator.of(context).markNeedsBuild();
                            setState(() {});
                          }
                        },
                        onVerticalDragEnd: (DragEndDetails details) {
                          double scrollVelocity =
                              details.velocity.pixelsPerSecond.dy;

                          if (scrollVelocity > 0) {
                            sheetHeight = screenHeight * 0.05;
                            Navigator.of(context).pop();
                          } else if (scrollVelocity < 0) {
                            sheetHeight = screenHeight * 0.55;
                            setState(() {});
                            // Navigator.of(context).markNeedsBuild();
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'This is the content of the bottom sheet',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );

  // static void openBottomSheet(BuildContext context, {double? offset}) {
  //   Navigator.of(context).push(
  //     CustomRoute(
  //       page: Container(),
  //       offset: offset,
  //     ),
  //   );
  // }
}

// class ScaleCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
//   ScaleCupertinoPageRoute({
//     required super.builder,
//     super.settings,
//   });

//   @override
//   Widget buildPage(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation) {
//     final Widget child = builder(context);

//     return ScaleTransition(
//       scale: secondaryAnimation.drive(Tween<double>(begin: 1.0, end: 0.8)),
//       child: FadeTransition(
//         opacity: secondaryAnimation.drive(Tween<double>(begin: 1.0, end: 0.8)),
//         child: child,
//       ),
//     );
//   }
// }
