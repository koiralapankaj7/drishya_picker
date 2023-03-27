import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
  Widget _view() {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SimpleDraggable(
        // setting: const SDraggableSetting(
        //   maxPoint: SPoint(offset: 0.9),
        //   initialPoint: SPoint(offset: 0.45),
        //   minPoint: SPoint(offset: 0.2),
        //   // byPosition: true,
        // ),
        builder: (context, controller) {
          // return Container(
          //   color: Colors.red,
          //   alignment: Alignment.center,
          //   child: TextButton(
          //     onPressed: () {},
          //     child: const Text(
          //       'Click Me',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // );

          return ListView.builder(
            controller: controller,
            // physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) => Container(
              color: Colors.amber,
              height: 100,
              margin: const EdgeInsets.all(2),
              child: Text('$index'),
            ),
          );
        },
      ),
    );
  }

  Widget _view1() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 8),

            // Textfield
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Textfield
                  Expanded(child: _TextFieldView(onChanged: (value) {})),

                  // Gallery field
                  IconButton(
                    onPressed: () {
                      Widget builder(BuildContext context) {
                        return Scaffold(
                          backgroundColor: Colors.transparent,
                          body: Container(
                            margin: const EdgeInsets.all(64),
                            decoration:
                                const BoxDecoration(color: Colors.amber),
                            child: Center(
                              child: IconButton(
                                onPressed: Navigator.of(context).pop,
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ),
                        );
                      }

                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: builder));
                    },
                    icon: const Icon(Icons.open_in_browser),
                  ),

                  //
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return _view();

    return SimpleDraggableScope(
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.cyan,
          body: Builder(builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      log('Test tapped...');
                    },
                    child: const Text('Test'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Widget builder(context, controller) {
                        return _TestWidget(
                          title: 'Simple SHeet',
                          controller: controller,
                        );
                      }

                      final result = await SimpleDraggableScope.of(context)
                          .show<String>(builder: builder);

                      // final result = await showSimpleSheet(
                      //   context: context,
                      //   builder: builder,
                      // );

                      log("This is the result =>$result");
                    },
                    child: const Text('Open'),
                  ),
                ],
              ),
            );
          }),
        );
      }),
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

class _TestWidget extends StatefulWidget {
  const _TestWidget({
    required this.title,
    this.controller,
  });

  final String title;
  final ScrollController? controller;

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  @override
  void initState() {
    super.initState();
    // log('Init ======>>>> ');
  }

  @override
  void dispose() {
    // log('<<<<====== Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(widget.title)),
      body: Container(
        color: Colors.amber,
        alignment: Alignment.center,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop('Lamo Katha'),
          child: const Text('Pop'),
        ),
      ),
    );
  }
}
