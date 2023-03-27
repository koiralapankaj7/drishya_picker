import 'package:flutter/material.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToDetails() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 3),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DetailsPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-1, 0),
                ).animate(animation),
                child: child,
              ),
              FadeTransition(
                opacity: Tween<double>(
                  begin: 0.5,
                  end: 1,
                ).animate(secondaryAnimation),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: _navigateToDetails,
          child: const Text('Go to details'),
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text('Details page'),
        ),
      ),
    );
  }
}
