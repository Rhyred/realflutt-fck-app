import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Untuk ikon Google
import 'package:smart_parking_app/services/user_service.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  LoginSignupScreenState createState() => LoginSignupScreenState();
}

class LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLogin = true;
  bool _isLoading = false;
  final UserService _userService = UserService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      // Navigasi eksplisit untuk memastikan UI diperbarui
      Navigator.pushReplacementNamed(context, '/main_navigation');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Gagal masuk: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });
    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      _showErrorSnackbar('Kata sandi tidak cocok');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Buat profil dasar di Realtime Database setelah registrasi berhasil
        await _userService.updateUserProfile(
          userId: userCredential.user!.uid,
          name: userCredential.user!.displayName ??
              '', // Nama bisa kosong saat awal
          plateNumber: '', // Plat nomor kosong saat awal
          phoneNumber: '', // No HP kosong saat awal
          photoURL: userCredential.user!.photoURL ?? '',
        );
      }

      if (!mounted) return;
      // Arahkan ke halaman lengkapi profil setelah signup berhasil
      Navigator.pushReplacementNamed(context, '/complete_profile');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Gagal mendaftar: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Jika ini adalah pengguna baru dari Google, buat profil dasar untuk mereka
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _userService.updateUserProfile(
          userId: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          plateNumber: '',
          phoneNumber: '',
          photoURL: userCredential.user!.photoURL ?? '',
        );
      }

      if (!mounted) return;
      // Navigasi eksplisit untuk memastikan UI diperbarui
      Navigator.pushReplacementNamed(context, '/main_navigation');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Gagal masuk dengan Google: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // Navigasi akan ditangani oleh AuthWrapper
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Gagal masuk secara anonim: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hapus navigasi manual ke /dashboard karena AuthWrapper yang akan menangani
    // setelah state auth berubah.

    return Scaffold(
      // backgroundColor diatur oleh ThemeData -> scaffoldBackgroundColor
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Image.asset(
                        'assets/app_icon.png',
                        height: 200,
                        width: 120,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _isLogin ? 'Welcome To Project IoT' : 'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Warna dari tema
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'by S-Park D-02',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 40.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          // Menggunakan InputDecorationTheme
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16.0),
                      if (!_isLogin)
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          obscureText: true,
                        ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        // Style dari elevatedButtonTheme
                        onPressed: _isLoading
                            ? null
                            : (_isLogin
                                ? _signInWithEmailPassword
                                : _signUpWithEmailPassword),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextButton(
                        // Style dari textButtonTheme
                        onPressed: _isLoading ? null : _toggleForm,
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Sign Up'
                              : 'Already have an account? Login',
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Background putih
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .primary, // Teks ungu
                          side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary), // Border ungu
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0), // Padding disesuaikan
                        ),
                        icon: FaIcon(FontAwesomeIcons.google,
                            color: Theme.of(context).colorScheme.primary),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                              fontSize: 16.0), // Ukuran font disesuaikan
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      OutlinedButton(
                        // Menggunakan OutlinedButton
                        onPressed: _isLoading ? null : _signInAnonymously,
                        // Style dari outlinedButtonTheme
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      Text(
                        '© ${DateTime.now().year} Smart Parking Team. All rights reserved.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (_isLoading)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
