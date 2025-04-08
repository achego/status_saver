import 'package:flutter/material.dart';
import 'package:status_saver/app/shared/components/custom_button.dart';
import 'package:status_saver/core/utils/app_assets.dart';

class PermissionModal extends StatelessWidget {
  const PermissionModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                height: 110,
                width: 150,
                child: Image.asset(
                  AppImages.storagePermission,
                  fit: BoxFit.cover,
                )),
            const SizedBox(height: 35),
            Text(
              'Storage',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              'Status Saver needs storage permission to save WhatsApp statuses.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
            ),
            const SizedBox(height: 35),
            CustomButton(
              title: 'Allow',
              onTap: () {
                Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(height: 15),
            CustomButton(
              filled: false,
              title: 'Skip',
              onTap: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
