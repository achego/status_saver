import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/core/theme/theme_provider.dart';

class ThemeIcon extends StatelessWidget {
  const ThemeIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        context.watch<ThemeProvider>().isDarkMode
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: () {
        context.read<ThemeProvider>().toggleTheme();
      },
    );
  }
}
