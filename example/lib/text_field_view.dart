import 'package:example/fullscreen_gallery.dart';
import 'package:flutter/material.dart';

///
class TextFieldView extends StatelessWidget {
  ///
  const TextFieldView({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  ///
  final ValueNotifier<Data> notifier;

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
          notifier.value = notifier.value.copyWith(
            maxLimit: max,
          );
        }
      },
    );
  }
}
