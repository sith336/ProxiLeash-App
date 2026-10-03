import 'package:flutter/material.dart';
import 'custom_card.dart';

class ClickableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ClickableCard({Key? key, required this.child, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        // Tap effect
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),

        // While pressing
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),

        // Desktop/web hover
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),

        child: child,
      ),
    );
  }
}
