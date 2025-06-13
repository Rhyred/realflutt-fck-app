import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_parking_app/theme_provider.dart'; // Import ThemeNotifier

class AccountSettingsScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const AccountSettingsScreen({super.key, required this.themeNotifier});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  Future<void> _logout() async {
    // Tidak perlu BuildContext sebagai parameter lagi, karena kita akan menggunakan context dari State
    try {
      await FirebaseAuth.instance.signOut();
      // Setelah await, periksa apakah widget masih mounted
      if (!mounted) return;

      // AuthWrapper akan menangani navigasi ke LoginScreen.
      // Cukup pop semua route di atas AuthWrapper (yang merupakan home).
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // AppBar dan backgroundColor akan mengambil dari tema
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        automaticallyImplyLeading:
            false, // Jika ini adalah tab utama di BottomNav
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            if (currentUser != null) ...[
              ListTile(
                leading: Icon(Icons.email,
                    color: Theme.of(context).colorScheme.primary),
                title: Text('Email',
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(
                  currentUser.email ?? 'Tidak ada email (Guest atau Anonim)',
                  // style default dari tema untuk subtitle
                ),
              ),
              const Divider(), // Menggunakan warna Divider dari tema
            ],
            ListTile(
              leading: Icon(Icons.history,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('Riwayat Booking',
                  style: Theme.of(context).textTheme.titleMedium),
              onTap: () {
                Navigator.pushNamed(context, '/booking_history');
              },
            ),
            const Divider(),
            SwitchListTile(
              title: Text('Mode Gelap',
                  style: Theme.of(context).textTheme.titleMedium),
              value: widget.themeNotifier.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                widget.themeNotifier.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              secondary: Icon(
                widget.themeNotifier.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Logout',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
