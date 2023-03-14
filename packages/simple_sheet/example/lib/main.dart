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
  @override
  Widget build(BuildContext context) {
    return SimpleSheetScaffold(
      child: Scaffold(
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
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_browser),
                    ),

                    //
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
