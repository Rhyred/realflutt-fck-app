import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: Colors.black, // Sesuaikan dengan tema
      ),
      backgroundColor: Colors.black, // Sesuaikan dengan tema
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            if (currentUser != null) ...[
              ListTile(
                leading: const Icon(Icons.email, color: Colors.white70),
                title:
                    const Text('Email', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                    currentUser.email ?? 'Tidak ada email (Guest atau Anonim)',
                    style: const TextStyle(color: Colors.white70)),
              ),
              const Divider(color: Colors.white24),
              // Tambahkan item lain di sini jika perlu (mis. ubah password)
            ],
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: _logout, // Panggil _logout tanpa context
            ),
          ],
        ),
      ),
    );
  }
}
