import 'package:flutter/material.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: svgAsset(icon, color: color ?? Colors.white),
      ),
    );
  }
}
