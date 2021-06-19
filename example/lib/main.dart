import 'package:example/collapsable_gallery.dart';
import 'package:example/controller_picker.dart';
import 'package:example/fillscreen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PickerDemo(),
    );
  }
}

class _PickerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FullscreenGallery()),
              );
            },
            child: const Text('Full screen mode'),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.green,
            ),
          ),
          const SizedBox(height: 20.0),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CollapsableGallery()),
              );
            },
            child: const Text('Collapsable mode'),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
