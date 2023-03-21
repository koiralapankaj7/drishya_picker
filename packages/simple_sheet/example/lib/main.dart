import 'dart:developer';

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
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: SimpleDraggable(
        builder: (context, controller) {
          return Container(
            color: Colors.green.withOpacity(0.7),
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                log('Pressed');
              },
              child: const Text('Click Me'),
            ),

            // child: ListView.builder(
            //   controller: controller,
            //   itemBuilder: (context, index) => Container(
            //     color: Colors.amber,
            //     height: 100,
            //     child: Text('$index'),
            //   ),
            // ),
          );
        },
      ),

//
      // body: DraggableScrollableSheet(
      //   snap: true,
      //   // expand: false,
      //   // minChildSize: 0.1,
      //   // initialChildSize: 0.1,
      //   // snapSizes: const [0.3, 0.5],
      //   builder: (context, controller) {
      //     return ListView.builder(
      //       controller: controller,
      //       itemBuilder: (context, index) => Container(
      //         color: Colors.amber,
      //         height: 100,
      //         child: Text('$index'),
      //       ),
      //     );
      //   },
      // ),
    );
    return SimpleSheet(
      body: Scaffold(
        backgroundColor: Colors.cyan,
        body: Builder(builder: (context) {
          return Container(
            color: Colors.green.withOpacity(0.4),
            alignment: Alignment.center,
            child: SimpleDraggable(
              builder: (context, scrollController) {
                return Container(color: Colors.amber);
              },
            ),
            // child: TextButton(
            //   onPressed: () {
            //     SimpleSheet.of(context).show((context, controller) {
            //       // return Container(color: Colors.amber);
            //       return Container(
            //         // alignment: Alignment
            //         //     .topCenter, // TODO remove alignment and see the size issue
            //         // child: TextButton(
            //         //   onPressed: Navigator.of(context).pop,
            //         //   child: const Text('Close'),
            //         // ),
            //         color: Colors.white,
            //         child: ListView.builder(
            //           controller: controller,
            //           itemBuilder: (context, index) {
            //             return Container(
            //               color: Colors.amber,
            //               margin: const EdgeInsets.all(2),
            //               padding: const EdgeInsets.all(16),
            //               child: Text('$index'),
            //             );
            //           },
            //         ),
            //       );
            //     });
            //     // Scaffold.of(context).showBottomSheet(
            //     //   (context) {
            //     //     return Container(color: Colors.amber);
            //     //     // return ListView.builder(
            //     //     //   itemBuilder: (context, index) => SizedBox(
            //     //     //     height: 100,
            //     //     //     child: Text('$index'),
            //     //     //   ),
            //     //     // );
            //     //   },
            //     //   enableDrag: true,
            //     // );
            //   },
            //   child: const Text('Open'),
            // ),
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
