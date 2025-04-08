import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:status_saver/core/utils/environments.dart';
import 'package:status_saver/core/utils/file_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Environments.email,
      queryParameters: {
        'subject': 'Status Saver App Feedback',
      },
    );

    await launchUrl(emailLaunchUri);
  }

  Future<void> _shareApp() async {
    await Share.share(
      'Check out this amazing Status Saver app!\n${Environments.appStoreUrl}',
      subject: 'Status Saver App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            _buildSection(
              context,
              title: 'App',
              items: [
                _SettingsItem(
                  icon: AppSvgs.share,
                  title: 'Share App',
                  onTap: _shareApp,
                ),
                _SettingsItem(
                  icon: AppSvgs.star,
                  title: 'Rate App',
                  onTap: () => _launchUrl(Environments.appStoreUrl),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    return _SettingsItem(
                      icon: AppSvgs.info,
                      title: 'Version',
                      subtitle: snapshot.data?.version ?? 'Loading...',
                    );
                  },
                ),
              ],
            ),
            Divider(),
            _buildSection(
              context,
              title: 'Storage',
              items: [
                FutureBuilder<String>(
                  future: FileUtils.getSavedStatusesDirectory()
                      .then((dir) => dir.path),
                  builder: (context, snapshot) {
                    return _SettingsItem(
                      icon: AppSvgs.folder,
                      title: 'Save Location',
                      subtitle: snapshot.data ?? 'Loading...',
                    );
                  },
                ),
              ],
            ),
            Divider(),
            _buildSection(
              context,
              title: 'Support',
              items: [
                _SettingsItem(
                  icon: AppSvgs.email,
                  title: 'Contact Developer',
                  subtitle: Environments.email,
                  onTap: _launchEmail,
                ),
                _SettingsItem(
                  icon: AppSvgs.shield,
                  title: 'Privacy Policy',
                  onTap: () => _launchUrl(Environments.privacyPolicyUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 35,
        width: 35,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          child: svgAsset(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
            )
          : null,
      onTap: onTap,
    );
  }
}
