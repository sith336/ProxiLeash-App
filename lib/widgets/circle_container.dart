import 'package:flutter/material.dart';
import 'package:proxileash/constants/themes.dart';

class CircleContainer extends StatelessWidget {
  final Widget child;

  const CircleContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 4.0),
      ),
      child: Center(child: child),
    );
  }
}
