import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.3, // 30% opacity
          child: Image.asset('assets/bg.png', fit: BoxFit.cover),
        ),
        child,
      ],
    );
  }
}
