import 'dart:ui';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'picker_1.dart';
import 'picker_2.dart';

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
      appBar: AppBar(
        title: const Text('Media Picker'),
      ),
      body: CameraView(),
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
                MaterialPageRoute(builder: (context) => Picker1()),
              );
            },
            child: const Text('Pick using controller'),
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
                MaterialPageRoute(builder: (context) => Picker2()),
              );
            },
            child: const Text('Pick without controller'),
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

class _SliderDemo extends StatefulWidget {
  @override
  __SliderDemoState createState() => __SliderDemoState();
}

class __SliderDemoState extends State<_SliderDemo> {
  final controller = SlideController(length: 3);

  @override
  Widget build(BuildContext context) {
    return SlideGesture(
      controller: controller,
      child: Container(
        height: 200.0,
        color: Colors.cyan,
        child: Center(
          child: _Indicator(controller: controller),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SlideController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SlideValue>(
      valueListenable: controller,
      builder: (context, state, child) {
        // This calculation is made for placing active index always in
        // center of the row.
        const minIndicatorWidth = 5.0 + 4.0; // 2.0 for margin
        const maxIndicatorWidth = 36.0;

        final baseTranslation =
            ((maxIndicatorWidth + ((state.length - 1) * minIndicatorWidth)) /
                    2) -
                (maxIndicatorWidth / 2);

        var translation =
            baseTranslation - (state.currentIndex * minIndicatorWidth);

        if (state.direction == SlideDirection.leftToRight) {
          translation += minIndicatorWidth * state.slidePercent;
        } else if (state.direction == SlideDirection.rightToLeft) {
          translation -= minIndicatorWidth * state.slidePercent;
        }

        // Pager indicator return column which first child is expended so that we
        // can place indicators at the bottom.

        return Transform(
          transform: Matrix4.translationValues(translation, 0.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              state.length,
              (index) {
                double? percentActive;

                if (index == state.currentIndex) {
                  percentActive = 1.0 - state.slidePercent;
                } else if (index == state.currentIndex - 1 &&
                    state.direction == SlideDirection.leftToRight) {
                  percentActive = state.slidePercent;
                } else if (index == state.currentIndex + 1 &&
                    state.direction == SlideDirection.rightToLeft) {
                  percentActive = state.slidePercent;
                } else {
                  percentActive = 0.0;
                }

                // Calculation isHollow
                final isHollow = index > state.currentIndex ||
                    (index == state.currentIndex &&
                        state.direction == SlideDirection.leftToRight);

                return Indicator(
                  isHollow: isHollow,
                  activePercent: percentActive,
                  isActive: state.currentIndex == index,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class Indicator extends StatelessWidget {
  ///
  const Indicator({
    Key? key,
    this.icon,
    this.color,
    this.isHollow,
    this.activePercent,
    this.isActive,
  }) : super(key: key);

  ///
  final IconData? icon;

  ///
  final Color? color;

  ///
  final bool? isHollow;

  ///
  final double? activePercent;

  ///
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
      child: Center(
        child: Container(
          height: lerpDouble(5.0, 5.0, activePercent!),
          width: lerpDouble(5.0, 36.0, activePercent!),
          margin: const EdgeInsets.only(right: 4.0),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(
              (0xFF * activePercent!.clamp(0.2, 1.0)).round(),
            ),
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
      ),
    );
  }
}
