import 'package:flutter/material.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.isLoading = false,
  });

  final String icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 45,
      padding: const EdgeInsets.all(12),
      child: isLoading
          ? CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            )
          : FittedBox(
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: svgAsset(icon, color: color ?? Colors.white),
              ),
            ),
    );
  }
}
