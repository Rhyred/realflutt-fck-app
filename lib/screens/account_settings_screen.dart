import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_parking_app/services/user_service.dart';
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
  final UserService _userService = UserService();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = _currentUser?.displayName ?? '';
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      final userProfile = await _userService.getUserProfile(_currentUser.uid);
      if (userProfile != null && mounted) {
        setState(() {
          _noHpController.text = userProfile['phoneNumber'] ?? '';
          _platNomorController.text = userProfile['plateNumber'] ?? '';
        });
      }
    }
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
      if (!mounted) return;
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

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sesi tidak valid. Silakan login kembali.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoURL = _currentUser.photoURL;

      // 1. Upload gambar jika ada yang baru
      if (_imageFile != null) {
        photoURL = await _userService.uploadProfileImage(
            _currentUser.uid, _imageFile!);
      }

      // 2. Update profil di Firebase Auth
      if (_namaController.text != _currentUser.displayName) {
        await _currentUser.updateDisplayName(_namaController.text);
      }
      if (photoURL != null && photoURL != _currentUser.photoURL) {
        await _currentUser.updatePhotoURL(photoURL);
      }

      // 3. Update profil di Realtime Database
      await _userService.updateUserProfile(
        userId: _currentUser.uid,
        name: _namaController.text,
        plateNumber: _platNomorController.text,
        phoneNumber: _noHpController.text,
        photoURL: photoURL,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        FocusScope.of(context).unfocus();
      }
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
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                onPressed: _isLoading ? null : _saveProfile,
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
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
