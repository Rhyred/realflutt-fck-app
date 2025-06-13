import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_parking_app/services/user_service.dart'; // Import UserService yang sebenarnya

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  bool _isLoading = false;

  final UserService _userService =
      UserService(); // Gunakan instance UserService

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Pengguna tidak ditemukan. Silakan login ulang.')),
          );
          // Mungkin navigasi ke login
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        // Simpan nama ke Firebase Auth Profile (opsional)
        if (_nameController.text.trim().isNotEmpty) {
          await currentUser.updateDisplayName(_nameController.text.trim());
        }

        // Simpan semua data ke Realtime Database menggunakan UserService
        await _userService.updateUserProfile(
          userId: currentUser.uid,
          name: _nameController.text.trim(),
          plateNumber: _plateController.text
              .trim()
              .toUpperCase(), // Simpan plat sebagai uppercase
          rfidTag: _rfidController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil disimpan!')),
          );
          // Navigasi ke halaman utama/dashboard setelah profil disimpan
          // Karena AuthWrapper akan menangani state, kita bisa popUntil root
          // atau jika ini adalah bagian dari alur awal, pastikan AuthWrapper
          // sekarang akan mengarahkan ke MainNavigationScreen.
          // Untuk memastikan, kita bisa pushReplacementNamed ke rute yang sesuai
          // atau biarkan AuthWrapper yang menangani jika sudah ada pengecekan profil lengkap.
          // Untuk saat ini, kita anggap setelah ini, AuthWrapper akan membawa ke main app.
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/main_navigation', (route) => false);
          // Atau jika ingin AuthWrapper yang handle: Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan profil: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil Anda'),
        // otomatis ada tombol back jika di-push
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text(
                'Selamat Datang!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Mohon lengkapi data berikut untuk melanjutkan.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Plat Kendaraan',
                  hintText: 'Contoh: B 1234 XYZ',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor plat tidak boleh kosong';
                  }
                  // Validasi format plat bisa ditambahkan di sini
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _rfidController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kartu RFID (Opsional)',
                  hintText: 'Tempelkan kartu atau masukkan manual',
                  prefixIcon: Icon(Icons.nfc),
                ),
                // validator: (value) {
                //   // Validasi jika diperlukan
                //   return null;
                // },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Simpan & Lanjutkan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
