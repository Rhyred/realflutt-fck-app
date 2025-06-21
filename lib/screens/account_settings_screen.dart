import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_parking_app/theme_provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _platNomorController = TextEditingController();

  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _namaController.text = _currentUser?.displayName ?? '';
    // TODO: Muat data no HP & plat dari database jika ada
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _platNomorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementasikan logika penyimpanan data:
      // 1. Update display name di Firebase Auth: _currentUser.updateDisplayName(_namaController.text)
      // 2. Upload _imageFile ke Firebase Storage jika tidak null.
      // 3. Dapatkan URL gambar setelah upload.
      // 4. Update photoURL di Firebase Auth: _currentUser.updatePhotoURL(imageUrl)
      // 5. Simpan no HP dan plat nomor ke Firestore/RTDB.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profil berhasil disimpan!'),
            backgroundColor: Colors.green),
      );
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _logout() async {
    try {
      final navigator = Navigator.of(context);
      await FirebaseAuth.instance.signOut();
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal logout: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier =
        ModalRoute.of(context)!.settings.arguments as ThemeNotifier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Keamanan'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_currentUser?.photoURL != null
                              ? NetworkImage(_currentUser!.photoURL!)
                              : null) as ImageProvider?,
                      child:
                          _imageFile == null && _currentUser?.photoURL == null
                              ? Icon(Icons.person,
                                  size: 60, color: Colors.grey.shade800)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                          onPressed: () => _showPicker(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextFormField(
                  controller: _namaController,
                  labelText: 'Nama Lengkap',
                  icon: Icons.person_outline),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _currentUser?.email ?? 'Tidak ada email',
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  filled: true,
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                  controller: _noHpController,
                  labelText: 'Nomor HP',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextFormField(
                  controller: _platNomorController,
                  labelText: 'Plat Nomor',
                  icon: Icons.directions_car_outlined,
                  textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                onPressed: _saveProfile,
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const Divider(height: 40),
              SwitchListTile(
                title: const Text('Mode Gelap'),
                value: themeNotifier.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  themeNotifier.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                secondary: Icon(
                  themeNotifier.themeMode == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Logout',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
