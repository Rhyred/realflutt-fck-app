import 'package:flutter/material.dart';
import 'package:smart_parking_app/theme_provider.dart'; // Diperlukan untuk meneruskan themeNotifier

class SettingsHubScreen extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const SettingsHubScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Akun'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Profil & Keamanan',
            subtitle: 'Ubah detail profil dan plat nomor',
            onTap: () {
              // Teruskan themeNotifier ke AccountSettingsScreen
              Navigator.pushNamed(context, '/account_settings',
                  arguments: themeNotifier);
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildSectionHeader(context, 'Aplikasi'),
          _buildSettingsTile(
            context,
            icon: Icons.history,
            title: 'Riwayat Booking',
            subtitle: 'Lihat semua transaksi pemesanan Anda',
            onTap: () {
              Navigator.pushNamed(context, '/booking_history');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Lihat versi aplikasi dan tim pengembang',
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
