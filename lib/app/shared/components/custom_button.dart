import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.title,
    this.filled = true,
    this.onTap,
  });

  final String? title;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: filled
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(
          title ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: filled
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
