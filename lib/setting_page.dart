import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColor,),
          onPressed: () => Navigator.pop(context),
        ),

        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Settings',

          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'General',
            children: [
              _buildSettingsTile(
                context,
                title: 'Theme',
                subtitle: 'System default',
                icon: Icons.palette_outlined,
                onTap: () => _showThemeDialog(context),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Data',
            children: [
              _buildSettingsTile(
                context,
                title: 'Clear History',
                subtitle: 'Delete all saved QR codes',
                icon: Icons.delete_outline,
                onTap: () => _showClearHistoryDialog(context),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'About',
            children: [
              _buildSettingsTile(
                context,
                title: 'Version',
                subtitle: 'Check current version',
                icon: Icons.info_outline,
                onTap: () => _showVersionInfo(context),
              ),
              _buildSettingsTile(
                context,
                title: 'Privacy Policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () => _launchURL('https://yourwebsite.com/privacy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required String title,
        String? subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('System'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Light'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all saved QR codes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final box = Hive.box('qrHistory');
              box.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _showVersionInfo(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('App Version'),
          content: Text('Version: ${packageInfo.version}\nBuild: ${packageInfo.buildNumber}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}