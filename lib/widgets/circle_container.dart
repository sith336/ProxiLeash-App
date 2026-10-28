import 'package:flutter/material.dart';
import 'glass_panel.dart';

class CircleContainer extends StatelessWidget {
  final Widget child;

  const CircleContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Center(child: child),
    );
  }
}
